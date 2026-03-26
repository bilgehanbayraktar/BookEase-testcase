using System.Security.Claims;
using BookEase.API.DTOs;
using BookEase.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BookEase.API.Controllers;

[ApiController]
[Route("api/bookings")]
[Authorize]
public class BookingController : ControllerBase
{
    private readonly IBookingService _bookingService;

    public BookingController(IBookingService bookingService)
    {
        _bookingService = bookingService;
    }

    /// <summary>Create a booking. Customer books for themselves; Admin can specify a CustomerId.</summary>
    [HttpPost]
    [Authorize(Roles = "Customer,Admin")]
    [ProducesResponseType(typeof(BookingResponseDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> Create([FromBody] CreateBookingDto dto)
    {
        var (userId, userRole) = GetCaller();
        // InvalidOperationException (slot full) → 409 via ErrorHandlingMiddleware
        var result = await _bookingService.CreateAsync(dto, userId, userRole);
        return StatusCode(StatusCodes.Status201Created, result);
    }

    /// <summary>Confirm a pending booking. BusinessOwner must own the business; Admin can confirm any.</summary>
    [HttpPut("{id:guid}/confirm")]
    [Authorize(Roles = "BusinessOwner,Admin")]
    [ProducesResponseType(typeof(BookingResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> Confirm([FromRoute] Guid id)
    {
        var (userId, userRole) = GetCaller();
        var result = await _bookingService.ConfirmAsync(id, userId, userRole);
        return Ok(result);
    }

    /// <summary>Cancel a booking. Customer cancels own; BusinessOwner cancels within their business; Admin cancels any.</summary>
    [HttpPut("{id:guid}/cancel")]
    [ProducesResponseType(typeof(BookingResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> Cancel([FromRoute] Guid id)
    {
        var (userId, userRole) = GetCaller();
        var result = await _bookingService.CancelAsync(id, userId, userRole);
        return Ok(result);
    }

    /// <summary>Get the current customer's bookings with optional status filter and pagination.</summary>
    [HttpGet("my")]
    [Authorize(Roles = "Customer")]
    [ProducesResponseType(typeof(PagedResultDto<BookingResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetMy(
        [FromQuery] string? status,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
    {
        var (userId, _) = GetCaller();
        var result = await _bookingService.GetByCustomerAsync(userId, status, page, pageSize);
        return Ok(result);
    }

    /// <summary>Get bookings for a business with optional date range filter and pagination.</summary>
    [HttpGet("/api/businesses/{businessId:guid}/bookings")]
    [Authorize(Roles = "BusinessOwner,Admin")]
    [ProducesResponseType(typeof(PagedResultDto<BookingResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetByBusiness(
        [FromRoute] Guid businessId,
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
    {
        var (userId, userRole) = GetCaller();
        var result = await _bookingService.GetByBusinessAsync(businessId, userId, userRole, from, to, page, pageSize);
        return Ok(result);
    }

    // ── Helper ────────────────────────────────────────────────────────────────────
    private (Guid userId, string userRole) GetCaller()
    {
        var rawId = User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException("User identity not found in token.");
        var role = User.FindFirstValue(ClaimTypes.Role)
            ?? throw new UnauthorizedAccessException("User role not found in token.");
        return (Guid.Parse(rawId), role);
    }
}
