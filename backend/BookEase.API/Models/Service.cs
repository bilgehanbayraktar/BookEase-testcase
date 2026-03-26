namespace BookEase.API.Models;

public class Service
{
    public Guid Id { get; set; }
    public Guid BusinessId { get; set; }
    public string Name { get; set; } = string.Empty;
    public int DurationMinutes { get; set; }
    public decimal Price { get; set; }
    public int Capacity { get; set; }
    public bool IsActive { get; set; }

    // Navigation
    public Business Business { get; set; } = null!;
    public ICollection<Slot> Slots { get; set; } = new List<Slot>();
}
