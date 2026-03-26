using BookEase.API.DTOs;

namespace BookEase.API.Services;

public interface IBusinessService
{
    Task<BusinessResponseDto> CreateAsync(CreateBusinessDto dto, Guid userId, string userRole);
    Task<IEnumerable<BusinessResponseDto>> GetAllAsync();
    Task<BusinessResponseDto> GetByIdAsync(Guid id);
    Task<BusinessResponseDto> UpdateAsync(Guid id, UpdateBusinessDto dto, Guid userId, string userRole);
    Task DeleteAsync(Guid id, Guid userId, string userRole);
}
