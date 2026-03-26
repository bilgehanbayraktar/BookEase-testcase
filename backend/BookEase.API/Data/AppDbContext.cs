using BookEase.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BookEase.API.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Business> Businesses => Set<Business>();
    public DbSet<Service> Services => Set<Service>();
    public DbSet<Slot> Slots => Set<Slot>();
    public DbSet<Booking> Bookings => Set<Booking>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // ── User ────────────────────────────────────────────────────────────
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(u => u.Id);
            entity.Property(u => u.Id).HasDefaultValueSql("gen_random_uuid()");
            entity.HasIndex(u => u.Email).IsUnique();
            entity.Property(u => u.Email).IsRequired().HasMaxLength(256);
            entity.Property(u => u.PasswordHash).IsRequired();
            entity.Property(u => u.FullName).IsRequired().HasMaxLength(200);
            entity.Property(u => u.Role).HasConversion<string>();
            entity.Property(u => u.CreatedAt).HasDefaultValueSql("now()");
        });

        // ── Business ────────────────────────────────────────────────────────
        modelBuilder.Entity<Business>(entity =>
        {
            entity.HasKey(b => b.Id);
            entity.Property(b => b.Id).HasDefaultValueSql("gen_random_uuid()");
            entity.Property(b => b.Name).IsRequired().HasMaxLength(200);
            entity.Property(b => b.Category).IsRequired().HasMaxLength(100);
            entity.Property(b => b.IsActive).HasDefaultValue(true);
            entity.Property(b => b.CreatedAt).HasDefaultValueSql("now()");

            entity.HasOne(b => b.Owner)
                  .WithMany(u => u.Businesses)
                  .HasForeignKey(b => b.OwnerId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // ── Service ─────────────────────────────────────────────────────────
        modelBuilder.Entity<Service>(entity =>
        {
            entity.HasKey(s => s.Id);
            entity.Property(s => s.Id).HasDefaultValueSql("gen_random_uuid()");
            entity.Property(s => s.Name).IsRequired().HasMaxLength(200);
            entity.Property(s => s.Price).HasColumnType("numeric(10,2)");
            entity.Property(s => s.IsActive).HasDefaultValue(true);

            entity.HasOne(s => s.Business)
                  .WithMany(b => b.Services)
                  .HasForeignKey(s => s.BusinessId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // ── Slot ────────────────────────────────────────────────────────────
        modelBuilder.Entity<Slot>(entity =>
        {
            entity.HasKey(sl => sl.Id);
            entity.Property(sl => sl.Id).HasDefaultValueSql("gen_random_uuid()");
            entity.Property(sl => sl.IsActive).HasDefaultValue(true);
            entity.Property(sl => sl.CurrentBookings).HasDefaultValue(0);

            entity.HasOne(sl => sl.Service)
                  .WithMany(s => s.Slots)
                  .HasForeignKey(sl => sl.ServiceId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // ── Booking ─────────────────────────────────────────────────────────
        modelBuilder.Entity<Booking>(entity =>
        {
            entity.HasKey(bk => bk.Id);
            entity.Property(bk => bk.Id).HasDefaultValueSql("gen_random_uuid()");
            entity.Property(bk => bk.Status).HasConversion<string>();
            entity.Property(bk => bk.CreatedAt).HasDefaultValueSql("now()");

            entity.HasOne(bk => bk.Slot)
                  .WithMany(sl => sl.Bookings)
                  .HasForeignKey(bk => bk.SlotId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(bk => bk.Customer)
                  .WithMany(u => u.Bookings)
                  .HasForeignKey(bk => bk.CustomerId)
                  .OnDelete(DeleteBehavior.Restrict);
        });
    }
}
