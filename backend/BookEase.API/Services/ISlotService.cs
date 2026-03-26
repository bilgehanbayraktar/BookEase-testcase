using BookEase.API.DTOs;

namespace BookEase.API.Services;

public interface ISlotService
{
    Task<SlotResponseDto> CreateAsync(Guid serviceId, CreateSlotDto dto, Guid userId, string userRole);
    Task<int> BulkCreateAsync(Guid serviceId, BulkCreateSlotDto dto, Guid userId, string userRole);
    Task<IEnumerable<SlotResponseDto>> GetByServiceAsync(Guid serviceId, DateTime? date);
    Task DeleteAsync(Guid serviceId, Guid slotId, Guid userId, string userRole);
}
