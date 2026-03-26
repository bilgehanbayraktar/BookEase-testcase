using BookEase.API.Data;
using BookEase.API.DTOs;
using BookEase.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BookEase.API.Services;

public class BookingService : IBookingService
{
    private readonly AppDbContext _db;
    private readonly ICacheService _cache;

    private static string SlotKey(Guid serviceId) => $"slots:service:{serviceId}";

    public BookingService(AppDbContext db, ICacheService cache)
    {
        _db    = db;
        _cache = cache;
    }

    public async Task<BookingResponseDto> CreateAsync(CreateBookingDto dto, Guid userId, string userRole)
    {
        var slot = await _db.Slots
            .Include(s => s.Service)
                .ThenInclude(svc => svc.Business)
            .FirstOrDefaultAsync(s => s.Id == dto.SlotId)
            ?? throw new KeyNotFoundException($"Slot {dto.SlotId} not found.");

        if (!slot.IsActive)
            throw new InvalidOperationException("Slot is not available.");

        if (!slot.Service.IsActive)
            throw new InvalidOperationException("Service is not active.");

        if (!slot.Service.Business.IsActive)
            throw new InvalidOperationException("Business is not active.");

        if (slot.CurrentBookings >= slot.Service.Capacity)
            throw new InvalidOperationException("Slot is fully booked.");

        Guid customerId;

        if (userRole == "Admin")
        {
            if (dto.CustomerId is null)
                throw new ArgumentException("CustomerId is required when booking as Admin.");

            var customer = await _db.Users.FindAsync(dto.CustomerId.Value)
                ?? throw new KeyNotFoundException($"User {dto.CustomerId} not found.");

            if (customer.Role != UserRole.Customer)
                throw new ArgumentException("CustomerId must refer to a user with the Customer role.");

            customerId = dto.CustomerId.Value;
        }
        else
        {
            // Customer role: always book as themselves
            customerId = userId;
        }

        var booking = new Booking
        {
            Id         = Guid.NewGuid(),
            SlotId     = dto.SlotId,
            CustomerId = customerId,
            Status     = BookingStatus.Pending,
            Note       = dto.Note,
            CreatedAt  = DateTime.UtcNow
        };

        slot.CurrentBookings++;

        _db.Bookings.Add(booking);
        await _db.SaveChangesAsync();
        await _cache.RemoveByPrefixAsync(SlotKey(slot.ServiceId));

        // Re-fetch customer for response mapping
        var customerUser = await _db.Users.FindAsync(customerId);

        return MapToDto(booking, slot, customerUser!);
    }

    public async Task<BookingResponseDto> ConfirmAsync(Guid bookingId, Guid userId, string userRole)
    {
        var booking = await LoadBookingWithDetails(bookingId);

        if (booking.Status != BookingStatus.Pending)
            throw new InvalidOperationException("Only pending bookings can be confirmed.");

        if (userRole == "BusinessOwner")
        {
            var business = booking.Slot.Service.Business;
            if (business.OwnerId != userId)
                throw new UnauthorizedAccessException("You don't own the business for this booking.");
        }

        booking.Status = BookingStatus.Confirmed;

        await _db.SaveChangesAsync();

        return MapToDto(booking, booking.Slot, booking.Customer);
    }

    public async Task<BookingResponseDto> CancelAsync(Guid bookingId, Guid userId, string userRole)
    {
        var booking = await LoadBookingWithDetails(bookingId);

        if (booking.Status == BookingStatus.Cancelled)
            throw new InvalidOperationException("Booking is already cancelled.");

        switch (userRole)
        {
            case "Customer":
                if (booking.CustomerId != userId)
                    throw new UnauthorizedAccessException("You can only cancel your own bookings.");
                break;
            case "BusinessOwner":
                if (booking.Slot.Service.Business.OwnerId != userId)
                    throw new UnauthorizedAccessException("You don't own the business for this booking.");
                break;
            // Admin: no check needed
        }

        booking.Status      = BookingStatus.Cancelled;
        booking.CancelledAt = DateTime.UtcNow;
        booking.Slot.CurrentBookings--;

        await _db.SaveChangesAsync();
        await _cache.RemoveByPrefixAsync(SlotKey(booking.Slot.ServiceId));

        return MapToDto(booking, booking.Slot, booking.Customer);
    }

    public async Task<PagedResultDto<BookingResponseDto>> GetByCustomerAsync(
        Guid customerId, string? status, int page, int pageSize)
    {
        var query = _db.Bookings
            .Include(b => b.Customer)
            .Include(b => b.Slot)
                .ThenInclude(s => s.Service)
                    .ThenInclude(svc => svc.Business)
            .Where(b => b.CustomerId == customerId);

        if (!string.IsNullOrEmpty(status) && Enum.TryParse<BookingStatus>(status, ignoreCase: true, out var parsed))
            query = query.Where(b => b.Status == parsed);

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderByDescending(b => b.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return new PagedResultDto<BookingResponseDto>
        {
            Items      = items.Select(b => MapToDto(b, b.Slot, b.Customer)).ToList(),
            TotalCount = totalCount,
            Page       = page,
            PageSize   = pageSize
        };
    }

    public async Task<PagedResultDto<BookingResponseDto>> GetByBusinessAsync(
        Guid businessId, Guid userId, string userRole, DateTime? from, DateTime? to, int page, int pageSize)
    {
        var business = await _db.Businesses.FindAsync(businessId)
            ?? throw new KeyNotFoundException($"Business {businessId} not found.");

        if (userRole == "BusinessOwner" && business.OwnerId != userId)
            throw new UnauthorizedAccessException("You don't own this business.");

        var query = _db.Bookings
            .Include(b => b.Customer)
            .Include(b => b.Slot)
                .ThenInclude(s => s.Service)
                    .ThenInclude(svc => svc.Business)
            .Where(b => b.Slot.Service.BusinessId == businessId);

        if (from.HasValue)
            query = query.Where(b => b.CreatedAt >= from.Value.Date);

        if (to.HasValue)
            query = query.Where(b => b.CreatedAt < to.Value.Date.AddDays(1));

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderByDescending(b => b.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return new PagedResultDto<BookingResponseDto>
        {
            Items      = items.Select(b => MapToDto(b, b.Slot, b.Customer)).ToList(),
            TotalCount = totalCount,
            Page       = page,
            PageSize   = pageSize
        };
    }

    // ── Helpers ──────────────────────────────────────────────────────────────────

    private async Task<Booking> LoadBookingWithDetails(Guid bookingId)
    {
        return await _db.Bookings
            .Include(b => b.Customer)
            .Include(b => b.Slot)
                .ThenInclude(s => s.Service)
                    .ThenInclude(svc => svc.Business)
            .FirstOrDefaultAsync(b => b.Id == bookingId)
            ?? throw new KeyNotFoundException($"Booking {bookingId} not found.");
    }

    private static BookingResponseDto MapToDto(Booking booking, Slot slot, User customer) => new()
    {
        Id            = booking.Id,
        SlotId        = booking.SlotId,
        SlotStartTime = slot.StartTime,
        SlotEndTime   = slot.EndTime,
        ServiceName   = slot.Service.Name,
        BusinessName  = slot.Service.Business.Name,
        CustomerName  = customer.FullName,
        CustomerEmail = customer.Email,
        Status        = booking.Status,
        Note          = booking.Note,
        CreatedAt     = booking.CreatedAt,
        CancelledAt   = booking.CancelledAt
    };
}
