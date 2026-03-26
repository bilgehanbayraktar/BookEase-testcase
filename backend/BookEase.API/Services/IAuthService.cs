using BookEase.API.DTOs;

namespace BookEase.API.Services;

public interface IAuthService
{
    Task<AuthResponseDto> RegisterAsync(RegisterDto dto);
    Task<AuthResponseDto> LoginAsync(LoginDto dto);
    Task<AuthResponseDto> RefreshTokenAsync(RefreshTokenDto dto);
    Task<AuthResponseDto> CreateAdminAsync(RegisterDto dto);
}
