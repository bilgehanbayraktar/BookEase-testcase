using BookEase.API.DTOs;

namespace BookEase.API.Services;

public interface IBookingService
{
    Task<BookingResponseDto> CreateAsync(CreateBookingDto dto, Guid userId, string userRole);
    Task<BookingResponseDto> ConfirmAsync(Guid bookingId, Guid userId, string userRole);
    Task<BookingResponseDto> CancelAsync(Guid bookingId, Guid userId, string userRole);
    Task<PagedResultDto<BookingResponseDto>> GetByCustomerAsync(Guid customerId, string? status, int page, int pageSize);
    Task<PagedResultDto<BookingResponseDto>> GetByBusinessAsync(Guid businessId, Guid userId, string userRole, DateTime? from, DateTime? to, int page, int pageSize);
}
