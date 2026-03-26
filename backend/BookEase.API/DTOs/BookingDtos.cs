using System.ComponentModel.DataAnnotations;
using BookEase.API.Models;

namespace BookEase.API.DTOs;

public class CreateBookingDto
{
    [Required(ErrorMessage = "SlotId is required.")]
    public Guid SlotId { get; set; }

    /// <summary>Only used by Admin to book on behalf of a customer. Ignored for Customer role.</summary>
    public Guid? CustomerId { get; set; }

    public string? Note { get; set; }
}

public class BookingResponseDto
{
    public Guid Id { get; set; }
    public Guid SlotId { get; set; }
    public DateTime SlotStartTime { get; set; }
    public DateTime SlotEndTime { get; set; }
    public string ServiceName { get; set; } = string.Empty;
    public string BusinessName { get; set; } = string.Empty;
    public string CustomerName { get; set; } = string.Empty;
    public string CustomerEmail { get; set; } = string.Empty;
    public BookingStatus Status { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? CancelledAt { get; set; }
}
