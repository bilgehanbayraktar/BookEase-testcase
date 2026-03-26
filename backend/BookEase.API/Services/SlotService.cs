using BookEase.API.Data;
using BookEase.API.DTOs;
using BookEase.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BookEase.API.Services;

public class SlotService : ISlotService
{
    private readonly AppDbContext _db;
    private readonly ICacheService _cache;

    private static readonly TimeSpan CacheTtl = TimeSpan.FromMinutes(2);
    private static string SlotKey(Guid serviceId) => $"slots:service:{serviceId}";

    public SlotService(AppDbContext db, ICacheService cache)
    {
        _db    = db;
        _cache = cache;
    }

    public async Task<SlotResponseDto> CreateAsync(Guid serviceId, CreateSlotDto dto, Guid userId, string userRole)
    {
        var service = await GetServiceAndAuthorize(serviceId, userId, userRole);

        var slot = new Slot
        {
            Id              = Guid.NewGuid(),
            ServiceId       = serviceId,
            StartTime       = dto.StartTime,
            EndTime         = dto.EndTime,
            CurrentBookings = 0,
            IsActive        = true
        };

        _db.Slots.Add(slot);
        await _db.SaveChangesAsync();
        await _cache.RemoveByPrefixAsync(SlotKey(serviceId));

        return MapToDto(slot, service);
    }

    public async Task<int> BulkCreateAsync(Guid serviceId, BulkCreateSlotDto dto, Guid userId, string userRole)
    {
        var service = await GetServiceAndAuthorize(serviceId, userId, userRole);

        var duration = dto.SlotDurationMinutes > 0
            ? TimeSpan.FromMinutes(dto.SlotDurationMinutes)
            : TimeSpan.FromMinutes(service.DurationMinutes);

        if (duration <= TimeSpan.Zero)
            throw new ArgumentException("Slot duration must be greater than zero.");

        if (dto.EndDate < dto.StartDate)
            throw new ArgumentException("EndDate must be on or after StartDate.");

        if (dto.EndHour <= dto.StartHour)
            throw new ArgumentException("EndHour must be after StartHour.");

        var slots = new List<Slot>();

        for (var day = dto.StartDate.Date; day <= dto.EndDate.Date; day = day.AddDays(1))
        {
            var slotStart = day + dto.StartHour;
            var dayEnd    = day + dto.EndHour;

            while (slotStart + duration <= dayEnd)
            {
                slots.Add(new Slot
                {
                    Id              = Guid.NewGuid(),
                    ServiceId       = serviceId,
                    StartTime       = slotStart,
                    EndTime         = slotStart + duration,
                    CurrentBookings = 0,
                    IsActive        = true
                });

                slotStart += duration;
            }
        }

        _db.Slots.AddRange(slots);
        await _db.SaveChangesAsync();
        await _cache.RemoveByPrefixAsync(SlotKey(serviceId));

        return slots.Count;
    }

    public async Task<IEnumerable<SlotResponseDto>> GetByServiceAsync(Guid serviceId, DateTime? date)
    {
        var service = await _db.Services.FindAsync(serviceId)
            ?? throw new KeyNotFoundException($"Service {serviceId} not found.");

        // Try cache first (always caches the full list for the service)
        var cacheKey = SlotKey(serviceId);
        var cached   = await _cache.GetAsync<List<SlotResponseDto>>(cacheKey);

        List<SlotResponseDto> all;

        if (cached is not null)
        {
            all = cached;
        }
        else
        {
            var slots = await _db.Slots
                .Where(s => s.ServiceId == serviceId && s.IsActive)
                .OrderBy(s => s.StartTime)
                .ToListAsync();

            all = slots.Select(s => MapToDto(s, service)).ToList();

            await _cache.SetAsync(cacheKey, all, CacheTtl);
        }

        // Apply date filter in-memory after cache retrieval
        if (date.HasValue)
        {
            var day = date.Value.Date;
            all = all.Where(s => s.StartTime.Date == day).ToList();
        }

        return all;
    }

    public async Task DeleteAsync(Guid serviceId, Guid slotId, Guid userId, string userRole)
    {
        await GetServiceAndAuthorize(serviceId, userId, userRole);

        var slot = await _db.Slots.FirstOrDefaultAsync(s => s.Id == slotId && s.ServiceId == serviceId)
            ?? throw new KeyNotFoundException($"Slot {slotId} not found.");

        slot.IsActive = false;

        await _db.SaveChangesAsync();
        await _cache.RemoveByPrefixAsync(SlotKey(serviceId));
    }

    // ── Helpers ──────────────────────────────────────────────────────────────────

    private async Task<Service> GetServiceAndAuthorize(Guid serviceId, Guid userId, string userRole)
    {
        var service = await _db.Services
            .Include(s => s.Business)
            .FirstOrDefaultAsync(s => s.Id == serviceId)
            ?? throw new KeyNotFoundException($"Service {serviceId} not found.");

        if (userRole != "Admin" && service.Business.OwnerId != userId)
            throw new UnauthorizedAccessException("You don't own the business this service belongs to.");

        return service;
    }

    private static SlotResponseDto MapToDto(Slot slot, Service service) => new()
    {
        Id              = slot.Id,
        ServiceId       = slot.ServiceId,
        ServiceName     = service.Name,
        StartTime       = slot.StartTime,
        EndTime         = slot.EndTime,
        CurrentBookings = slot.CurrentBookings,
        Capacity        = service.Capacity,
        IsAvailable     = slot.CurrentBookings < service.Capacity,
        IsActive        = slot.IsActive
    };
}
