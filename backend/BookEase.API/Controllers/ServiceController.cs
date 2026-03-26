using System.Security.Claims;
using BookEase.API.DTOs;
using BookEase.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BookEase.API.Controllers;

[ApiController]
[Route("api/businesses/{businessId:guid}/services")]
[Authorize]
public class ServiceController : ControllerBase
{
    private readonly IServiceService _serviceService;

    public ServiceController(IServiceService serviceService)
    {
        _serviceService = serviceService;
    }

    /// <summary>Create a service. BusinessOwner must own the business; Admin can add to any.</summary>
    [HttpPost]
    [Authorize(Roles = "BusinessOwner,Admin")]
    [ProducesResponseType(typeof(ServiceResponseDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Create([FromRoute] Guid businessId, [FromBody] CreateServiceDto dto)
    {
        var (userId, userRole) = GetCaller();
        var result = await _serviceService.CreateAsync(businessId, dto, userId, userRole);
        return CreatedAtAction(nameof(GetByBusiness), new { businessId }, result);
    }

    /// <summary>Get all active services for a business.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<ServiceResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetByBusiness([FromRoute] Guid businessId)
    {
        var result = await _serviceService.GetByBusinessAsync(businessId);
        return Ok(result);
    }

    /// <summary>Update a service. BusinessOwner must own the parent business; Admin can update any.</summary>
    [HttpPut("{id:guid}")]
    [Authorize(Roles = "BusinessOwner,Admin")]
    [ProducesResponseType(typeof(ServiceResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(
        [FromRoute] Guid businessId,
        [FromRoute] Guid id,
        [FromBody] UpdateServiceDto dto)
    {
        var (userId, userRole) = GetCaller();
        var result = await _serviceService.UpdateAsync(businessId, id, dto, userId, userRole);
        return Ok(result);
    }

    /// <summary>Soft-delete a service. BusinessOwner must own the parent business; Admin can delete any.</summary>
    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "BusinessOwner,Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete([FromRoute] Guid businessId, [FromRoute] Guid id)
    {
        var (userId, userRole) = GetCaller();
        await _serviceService.DeleteAsync(businessId, id, userId, userRole);
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
