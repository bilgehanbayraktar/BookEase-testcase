using System.Security.Claims;
using BookEase.API.DTOs;
using BookEase.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BookEase.API.Controllers;

[ApiController]
[Route("api/businesses")]
[Authorize]
public class BusinessController : ControllerBase
{
    private readonly IBusinessService _businessService;

    public BusinessController(IBusinessService businessService)
    {
        _businessService = businessService;
    }

    /// <summary>Create a new business. BusinessOwner uses their own identity; Admin must supply OwnerId.</summary>
    [HttpPost]
    [Authorize(Roles = "BusinessOwner,Admin")]
    [ProducesResponseType(typeof(BusinessResponseDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> Create([FromBody] CreateBusinessDto dto)
    {
        var (userId, userRole) = GetCaller();
        var result = await _businessService.CreateAsync(dto, userId, userRole);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    /// <summary>Get all active businesses.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<BusinessResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetAll()
    {
        var result = await _businessService.GetAllAsync();
        return Ok(result);
    }

    /// <summary>Get a single business by id (includes inactive).</summary>
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(BusinessResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById([FromRoute] Guid id)
    {
        var result = await _businessService.GetByIdAsync(id);
        return Ok(result);
    }

    /// <summary>Update a business. BusinessOwner must own it; Admin can update any.</summary>
    [HttpPut("{id:guid}")]
    [Authorize(Roles = "BusinessOwner,Admin")]
    [ProducesResponseType(typeof(BusinessResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update([FromRoute] Guid id, [FromBody] UpdateBusinessDto dto)
    {
        var (userId, userRole) = GetCaller();
        var result = await _businessService.UpdateAsync(id, dto, userId, userRole);
        return Ok(result);
    }

    /// <summary>Soft-delete a business and its services. BusinessOwner must own it; Admin can delete any.</summary>
    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "BusinessOwner,Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete([FromRoute] Guid id)
    {
        var (userId, userRole) = GetCaller();
        await _businessService.DeleteAsync(id, userId, userRole);
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
