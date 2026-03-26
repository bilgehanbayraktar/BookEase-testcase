using System.Security.Claims;
using BookEase.API.DTOs;
using BookEase.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BookEase.API.Controllers;

[ApiController]
[Route("api/services/{serviceId:guid}/slots")]
[Authorize]
public class SlotController : ControllerBase
{
    private readonly ISlotService _slotService;

    public SlotController(ISlotService slotService)
    {
        _slotService = slotService;
    }

    /// <summary>Create a single slot for a service.</summary>
    [HttpPost]
    [Authorize(Roles = "BusinessOwner,Admin")]
    [ProducesResponseType(typeof(SlotResponseDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Create([FromRoute] Guid serviceId, [FromBody] CreateSlotDto dto)
    {
        var (userId, userRole) = GetCaller();
        var result = await _slotService.CreateAsync(serviceId, dto, userId, userRole);
        return CreatedAtAction(nameof(GetByService), new { serviceId }, result);
    }

    /// <summary>Bulk-create slots for a date range and time window.</summary>
    [HttpPost("bulk")]
    [Authorize(Roles = "BusinessOwner,Admin")]
    [ProducesResponseType(typeof(object), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> BulkCreate([FromRoute] Guid serviceId, [FromBody] BulkCreateSlotDto dto)
    {
        var (userId, userRole) = GetCaller();
        var count = await _slotService.BulkCreateAsync(serviceId, dto, userId, userRole);
        return StatusCode(StatusCodes.Status201Created, new { createdCount = count });
    }

    /// <summary>List active slots for a service, optionally filtered by date.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<SlotResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetByService(
        [FromRoute] Guid serviceId,
        [FromQuery] DateTime? date)
    {
        var result = await _slotService.GetByServiceAsync(serviceId, date);
        return Ok(result);
    }

    /// <summary>Soft-delete a slot.</summary>
    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "BusinessOwner,Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete([FromRoute] Guid serviceId, [FromRoute] Guid id)
    {
        var (userId, userRole) = GetCaller();
        await _slotService.DeleteAsync(serviceId, id, userId, userRole);
        return NoContent();
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
