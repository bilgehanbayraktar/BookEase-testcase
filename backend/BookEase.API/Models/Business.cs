namespace BookEase.API.Models;

public class Business
{
    public Guid Id { get; set; }
    public Guid OwnerId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }

    // Navigation
    public User Owner { get; set; } = null!;
    public ICollection<Service> Services { get; set; } = new List<Service>();
}
