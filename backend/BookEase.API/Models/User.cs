namespace BookEase.API.Models;

public enum UserRole
{
    Customer,
    BusinessOwner,
    Admin
}

public class User
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public UserRole Role { get; set; }
    public string? RefreshToken { get; set; }
    public DateTime? RefreshTokenExpiry { get; set; }
    public DateTime CreatedAt { get; set; }

    // Navigation
    public ICollection<Business> Businesses { get; set; } = new List<Business>();
    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
}
