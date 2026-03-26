using System.ComponentModel.DataAnnotations;

namespace BookEase.API.DTOs;

public class CreateSlotDto : IValidatableObject
{
    [Required(ErrorMessage = "StartTime is required.")]
    public DateTime StartTime { get; set; }

    [Required(ErrorMessage = "EndTime is required.")]
    public DateTime EndTime { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (EndTime <= StartTime)
            yield return new ValidationResult(
                "EndTime must be after StartTime.",
                new[] { nameof(EndTime) });
    }
}

public class BulkCreateSlotDto
{
    [Required(ErrorMessage = "StartDate is required.")]
    public DateTime StartDate { get; set; }

    [Required(ErrorMessage = "EndDate is required.")]
    public DateTime EndDate { get; set; }

    [Required(ErrorMessage = "StartHour is required.")]
    public TimeSpan StartHour { get; set; }

    [Required(ErrorMessage = "EndHour is required.")]
    public TimeSpan EndHour { get; set; }

    /// <summary>
    /// Duration per slot in minutes. Pass 0 to use the service's DurationMinutes.
    /// </summary>
    public int SlotDurationMinutes { get; set; }
}

public class SlotResponseDto
{
    public Guid Id { get; set; }
    public Guid ServiceId { get; set; }
    public string ServiceName { get; set; } = string.Empty;
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public int CurrentBookings { get; set; }
    public int Capacity { get; set; }
    public bool IsAvailable { get; set; }
    public bool IsActive { get; set; }
}
