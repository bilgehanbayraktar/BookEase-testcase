using BookEase.API.DTOs;

namespace BookEase.API.Services;

public interface IServiceService
{
    Task<ServiceResponseDto> CreateAsync(Guid businessId, CreateServiceDto dto, Guid userId, string userRole);
    Task<IEnumerable<ServiceResponseDto>> GetByBusinessAsync(Guid businessId);
    Task<ServiceResponseDto> UpdateAsync(Guid businessId, Guid serviceId, UpdateServiceDto dto, Guid userId, string userRole);
    Task DeleteAsync(Guid businessId, Guid serviceId, Guid userId, string userRole);
}
