using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using BookEase.API.Data;
using BookEase.API.DTOs;
using BookEase.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace BookEase.API.Services;

public class AuthService : IAuthService
{
    private readonly AppDbContext _db;
    private readonly IConfiguration _config;

    public AuthService(AppDbContext db, IConfiguration config)
    {
        _db = db;
        _config = config;
    }

    // ── Register ────────────────────────────────────────────────────────────────
    public async Task<AuthResponseDto> RegisterAsync(RegisterDto dto)
    {
        var emailTaken = await _db.Users.AnyAsync(u => u.Email == dto.Email.ToLower());
        if (emailTaken)
            throw new InvalidOperationException("Email is already registered.");

        var role = ParseRole(dto.Role);

        if (role == UserRole.Admin)
            throw new UnauthorizedAccessException("Admin accounts cannot be self-registered.");

        var user = new User
        {
            Id           = Guid.NewGuid(),
            Email        = dto.Email.ToLower(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
            FullName     = dto.FullName,
            Role         = role,
            CreatedAt    = DateTime.UtcNow
        };

        var (accessToken, refreshToken, expiresAt) = GenerateTokens(user);
        user.RefreshToken       = refreshToken;
        user.RefreshTokenExpiry = DateTime.UtcNow.AddDays(RefreshTokenExpiryDays);

        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        return BuildResponse(user, accessToken, refreshToken, expiresAt);
    }

    // ── Create Admin (privileged, skips self-registration block) ────────────────
    public async Task<AuthResponseDto> CreateAdminAsync(RegisterDto dto)
    {
        var emailTaken = await _db.Users.AnyAsync(u => u.Email == dto.Email.ToLower());
        if (emailTaken)
            throw new InvalidOperationException("Email is already registered.");

        var user = new User
        {
            Id           = Guid.NewGuid(),
            Email        = dto.Email.ToLower(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
            FullName     = dto.FullName,
            Role         = UserRole.Admin,
            CreatedAt    = DateTime.UtcNow
        };

        var (accessToken, refreshToken, expiresAt) = GenerateTokens(user);
        user.RefreshToken       = refreshToken;
        user.RefreshTokenExpiry = DateTime.UtcNow.AddDays(RefreshTokenExpiryDays);

        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        return BuildResponse(user, accessToken, refreshToken, expiresAt);
    }

    // ── Login ───────────────────────────────────────────────────────────────────
    public async Task<AuthResponseDto> LoginAsync(LoginDto dto)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == dto.Email.ToLower())
            ?? throw new UnauthorizedAccessException("Invalid email or password.");

        if (!BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Invalid email or password.");

        var (accessToken, refreshToken, expiresAt) = GenerateTokens(user);
        user.RefreshToken       = refreshToken;
        user.RefreshTokenExpiry = DateTime.UtcNow.AddDays(RefreshTokenExpiryDays);

        await _db.SaveChangesAsync();

        return BuildResponse(user, accessToken, refreshToken, expiresAt);
    }

    // ── Refresh Token ────────────────────────────────────────────────────────────
    public async Task<AuthResponseDto> RefreshTokenAsync(RefreshTokenDto dto)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.RefreshToken == dto.RefreshToken)
            ?? throw new UnauthorizedAccessException("Invalid refresh token.");

        if (user.RefreshTokenExpiry is null || user.RefreshTokenExpiry < DateTime.UtcNow)
            throw new UnauthorizedAccessException("Refresh token has expired.");

        var (accessToken, refreshToken, expiresAt) = GenerateTokens(user);
        user.RefreshToken       = refreshToken;
        user.RefreshTokenExpiry = DateTime.UtcNow.AddDays(RefreshTokenExpiryDays);

        await _db.SaveChangesAsync();

        return BuildResponse(user, accessToken, refreshToken, expiresAt);
    }

    // ── Helpers ──────────────────────────────────────────────────────────────────
    private (string accessToken, string refreshToken, DateTime expiresAt) GenerateTokens(User user)
    {
        var expiresAt   = DateTime.UtcNow.AddMinutes(AccessTokenExpiryMinutes);
        var accessToken = GenerateAccessToken(user, expiresAt);
        var refreshToken = GenerateRefreshToken();
        return (accessToken, refreshToken, expiresAt);
    }

    private string GenerateAccessToken(User user, DateTime expiresAt)
    {
        var key   = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(SecretKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub,   user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(JwtRegisteredClaimNames.Jti,   Guid.NewGuid().ToString()),
            new Claim(ClaimTypes.Role,               user.Role.ToString())
        };

        var token = new JwtSecurityToken(
            issuer:             _config["Jwt:Issuer"],
            audience:           _config["Jwt:Audience"],
            claims:             claims,
            notBefore:          DateTime.UtcNow,
            expires:            expiresAt,
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private static string GenerateRefreshToken()
    {
        var bytes = RandomNumberGenerator.GetBytes(64);
        return Convert.ToBase64String(bytes);
    }

    private static AuthResponseDto BuildResponse(
        User user, string accessToken, string refreshToken, DateTime expiresAt) => new()
    {
        AccessToken  = accessToken,
        RefreshToken = refreshToken,
        ExpiresAt    = expiresAt,
        User = new AuthUserDto
        {
            Id       = user.Id,
            Email    = user.Email,
            FullName = user.FullName,
            Role     = user.Role.ToString()
        }
    };

    private static UserRole ParseRole(string role) => role.ToLower() switch
    {
        "business_owner" => UserRole.BusinessOwner,
        "admin"          => UserRole.Admin,
        _                => UserRole.Customer
    };

    private string SecretKey            => _config["Jwt:SecretKey"]!;
    private int    AccessTokenExpiryMinutes => int.TryParse(_config["Jwt:AccessTokenExpiryMinutes"], out var m) ? m : 60;
    private int    RefreshTokenExpiryDays  => int.TryParse(_config["Jwt:RefreshTokenExpiryDays"],   out var d) ? d : 7;
}
