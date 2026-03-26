namespace BookEase.API.Models;

public class Slot
{
    public Guid Id { get; set; }
    public Guid ServiceId { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public int CurrentBookings { get; set; }
    public bool IsActive { get; set; }

    // Navigation
    public Service Service { get; set; } = null!;
    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
}
