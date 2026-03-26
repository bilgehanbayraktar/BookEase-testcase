using BookEase.API.Data;
using BookEase.API.DTOs;
using BookEase.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BookEase.API.Services;

public class ServiceService : IServiceService
{
    private readonly AppDbContext _db;

    public ServiceService(AppDbContext db)
    {
        _db = db;
    }

    public async Task<ServiceResponseDto> CreateAsync(Guid businessId, CreateServiceDto dto, Guid userId, string userRole)
    {
        await GetBusinessAndAuthorize(businessId, userId, userRole);

        var service = new Service
        {
            Id              = Guid.NewGuid(),
            BusinessId      = businessId,
            Name            = dto.Name,
            DurationMinutes = dto.DurationMinutes,
            Price           = dto.Price,
            Capacity        = dto.Capacity,
            IsActive        = true
        };

        _db.Services.Add(service);
        await _db.SaveChangesAsync();

        return MapToDto(service);
    }

    public async Task<IEnumerable<ServiceResponseDto>> GetByBusinessAsync(Guid businessId)
    {
        _ = await _db.Businesses.FindAsync(businessId)
            ?? throw new KeyNotFoundException($"Business {businessId} not found.");

        return await _db.Services
            .Where(s => s.BusinessId == businessId && s.IsActive)
            .Select(s => MapToDto(s))
            .ToListAsync();
    }

    public async Task<ServiceResponseDto> UpdateAsync(
        Guid businessId, Guid serviceId, UpdateServiceDto dto, Guid userId, string userRole)
    {
        await GetBusinessAndAuthorize(businessId, userId, userRole);

        var service = await _db.Services
            .FirstOrDefaultAsync(s => s.Id == serviceId && s.BusinessId == businessId)
            ?? throw new KeyNotFoundException($"Service {serviceId} not found.");

        service.Name            = dto.Name;
        service.DurationMinutes = dto.DurationMinutes;
        service.Price           = dto.Price;
        service.Capacity        = dto.Capacity;

        await _db.SaveChangesAsync();

        return MapToDto(service);
    }

    public async Task DeleteAsync(Guid businessId, Guid serviceId, Guid userId, string userRole)
    {
        await GetBusinessAndAuthorize(businessId, userId, userRole);

        var service = await _db.Services
            .FirstOrDefaultAsync(s => s.Id == serviceId && s.BusinessId == businessId)
            ?? throw new KeyNotFoundException($"Service {serviceId} not found.");

        service.IsActive = false;

        await _db.SaveChangesAsync();
    }

    // ── Helpers ──────────────────────────────────────────────────────────────────

    private async Task<Business> GetBusinessAndAuthorize(Guid businessId, Guid userId, string userRole)
    {
        var business = await _db.Businesses.FindAsync(businessId)
            ?? throw new KeyNotFoundException($"Business {businessId} not found.");

        if (userRole != "Admin" && business.OwnerId != userId)
            throw new UnauthorizedAccessException("You don't own this business.");

        return business;
    }

    private static ServiceResponseDto MapToDto(Service s) => new()
    {
        Id              = s.Id,
        Name            = s.Name,
        DurationMinutes = s.DurationMinutes,
        Price           = s.Price,
        Capacity        = s.Capacity,
        IsActive        = s.IsActive
    };
}
