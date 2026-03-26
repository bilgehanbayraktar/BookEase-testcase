namespace BookEase.API.Models;

public enum BookingStatus
{
    Pending,
    Confirmed,
    Cancelled
}

public class Booking
{
    public Guid Id { get; set; }
    public Guid SlotId { get; set; }
    public Guid CustomerId { get; set; }
    public BookingStatus Status { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? CancelledAt { get; set; }

    // Navigation
    public Slot Slot { get; set; } = null!;
    public User Customer { get; set; } = null!;
}
