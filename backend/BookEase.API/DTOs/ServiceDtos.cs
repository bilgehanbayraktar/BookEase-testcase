using System.ComponentModel.DataAnnotations;

namespace BookEase.API.DTOs;

public class CreateServiceDto
{
    [Required(ErrorMessage = "Name is required.")]
    [MaxLength(200, ErrorMessage = "Name cannot exceed 200 characters.")]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "DurationMinutes is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "DurationMinutes must be greater than 0.")]
    public int DurationMinutes { get; set; }

    [Required(ErrorMessage = "Price is required.")]
    [Range(0, double.MaxValue, ErrorMessage = "Price must be 0 or greater.")]
    public decimal Price { get; set; }

    [Required(ErrorMessage = "Capacity is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Capacity must be greater than 0.")]
    public int Capacity { get; set; }
}

public class UpdateServiceDto
{
    [Required(ErrorMessage = "Name is required.")]
    [MaxLength(200, ErrorMessage = "Name cannot exceed 200 characters.")]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "DurationMinutes is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "DurationMinutes must be greater than 0.")]
    public int DurationMinutes { get; set; }

    [Required(ErrorMessage = "Price is required.")]
    [Range(0, double.MaxValue, ErrorMessage = "Price must be 0 or greater.")]
    public decimal Price { get; set; }

    [Required(ErrorMessage = "Capacity is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Capacity must be greater than 0.")]
    public int Capacity { get; set; }
}

public class ServiceResponseDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int DurationMinutes { get; set; }
    public decimal Price { get; set; }
    public int Capacity { get; set; }
    public bool IsActive { get; set; }
}
