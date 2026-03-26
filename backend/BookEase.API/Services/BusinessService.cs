using BookEase.API.Data;
using BookEase.API.DTOs;
using BookEase.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BookEase.API.Services;

public class BusinessService : IBusinessService
{
    private readonly AppDbContext _db;
    private readonly ICacheService _cache;

    private const string ActiveBusinessesKey = "businesses:active";
    private static readonly TimeSpan CacheTtl = TimeSpan.FromMinutes(5);

    public BusinessService(AppDbContext db, ICacheService cache)
    {
        _db    = db;
        _cache = cache;
    }

    public async Task<BusinessResponseDto> CreateAsync(CreateBusinessDto dto, Guid userId, string userRole)
    {
        Guid ownerId;

        if (userRole == "Admin")
        {
            if (dto.OwnerId is null)
                throw new ArgumentException("OwnerId is required when creating a business as Admin.");

            if (dto.OwnerId == userId)
                throw new ArgumentException("Admin cannot set themselves as the business owner.");

            var owner = await _db.Users.FindAsync(dto.OwnerId.Value)
                ?? throw new KeyNotFoundException($"User {dto.OwnerId} not found.");

            if (owner.Role != UserRole.BusinessOwner)
                throw new ArgumentException("OwnerId must refer to a user with the BusinessOwner role.");

            ownerId = dto.OwnerId.Value;
        }
        else
        {
            // BusinessOwner: always use token identity, ignore dto.OwnerId
            ownerId = userId;
        }

        var business = new Business
        {
            Id          = Guid.NewGuid(),
            OwnerId     = ownerId,
            Name        = dto.Name,
            Category    = dto.Category,
            Description = dto.Description,
            IsActive    = true,
            CreatedAt   = DateTime.UtcNow
        };

        _db.Businesses.Add(business);
        await _db.SaveChangesAsync();
        await _cache.RemoveAsync(ActiveBusinessesKey);

        return await FetchResponseDto(business.Id);
    }

    public async Task<IEnumerable<BusinessResponseDto>> GetAllAsync()
    {
        var cached = await _cache.GetAsync<List<BusinessResponseDto>>(ActiveBusinessesKey);
        if (cached is not null) return cached;

        var result = await _db.Businesses
            .Where(b => b.IsActive)
            .Include(b => b.Owner)
            .Select(b => MapToDto(b))
            .ToListAsync();

        await _cache.SetAsync(ActiveBusinessesKey, result, CacheTtl);

        return result;
    }

    public async Task<BusinessResponseDto> GetByIdAsync(Guid id)
    {
        var business = await _db.Businesses
            .Include(b => b.Owner)
            .FirstOrDefaultAsync(b => b.Id == id)
            ?? throw new KeyNotFoundException($"Business {id} not found.");

        return MapToDto(business);
    }

    public async Task<BusinessResponseDto> UpdateAsync(Guid id, UpdateBusinessDto dto, Guid userId, string userRole)
    {
        var business = await GetBusinessAndAuthorize(id, userId, userRole);

        // Re-fetch with Owner for the response mapping
        await _db.Entry(business).Reference(b => b.Owner).LoadAsync();

        business.Name        = dto.Name;
        business.Category    = dto.Category;
        business.Description = dto.Description;

        await _db.SaveChangesAsync();
        await _cache.RemoveAsync(ActiveBusinessesKey);

        return MapToDto(business);
    }

    public async Task DeleteAsync(Guid id, Guid userId, string userRole)
    {
        var business = await _db.Businesses
            .Include(b => b.Services)
            .FirstOrDefaultAsync(b => b.Id == id)
            ?? throw new KeyNotFoundException($"Business {id} not found.");

        Authorize(business, userId, userRole);

        business.IsActive = false;

        foreach (var service in business.Services)
            service.IsActive = false;

        await _db.SaveChangesAsync();
        await _cache.RemoveAsync(ActiveBusinessesKey);
    }

    // ── Helpers ──────────────────────────────────────────────────────────────────

    private async Task<Business> GetBusinessAndAuthorize(Guid businessId, Guid userId, string userRole)
    {
        var business = await _db.Businesses.FindAsync(businessId)
            ?? throw new KeyNotFoundException($"Business {businessId} not found.");

        Authorize(business, userId, userRole);

        return business;
    }

    private static void Authorize(Business business, Guid userId, string userRole)
    {
        if (userRole != "Admin" && business.OwnerId != userId)
            throw new UnauthorizedAccessException("You don't own this business.");
    }

    private async Task<BusinessResponseDto> FetchResponseDto(Guid id)
    {
        var business = await _db.Businesses
            .Include(b => b.Owner)
            .FirstAsync(b => b.Id == id);

        return MapToDto(business);
    }

    private static BusinessResponseDto MapToDto(Business b) => new()
    {
        Id          = b.Id,
        Name        = b.Name,
        Category    = b.Category,
        Description = b.Description,
        IsActive    = b.IsActive,
        CreatedAt   = b.CreatedAt,
        Owner = new BusinessOwnerDto
        {
            Id       = b.Owner.Id,
            FullName = b.Owner.FullName,
            Email    = b.Owner.Email
        }
    };
}
