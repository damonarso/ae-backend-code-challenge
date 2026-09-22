using Ae.Maritime.Infrastructure.Persistence.Rows;
using Microsoft.EntityFrameworkCore;

namespace Ae.Maritime.Infrastructure.Persistence;

public sealed class MaritimeDbContext : DbContext
{
    public MaritimeDbContext(DbContextOptions<MaritimeDbContext> options) : base(options) { }

    internal DbSet<CrewListRow> CrewListRows => Set<CrewListRow>();
    internal DbSet<ShipSummaryRow> ShipSummaryRows => Set<ShipSummaryRow>();
    internal DbSet<ShipDetailRow> ShipDetailRows => Set<ShipDetailRow>();
    internal DbSet<UserSummaryRow> UserSummaryRows => Set<UserSummaryRow>();
    internal DbSet<UserDetailRow> UserDetailRows => Set<UserDetailRow>();
    internal DbSet<AssignedShipRow> AssignedShipRows => Set<AssignedShipRow>();
    internal DbSet<FinancialReportDetailRow> FinancialReportDetailRows => Set<FinancialReportDetailRow>();
    internal DbSet<FinancialReportSummaryRow> FinancialReportSummaryRows => Set<FinancialReportSummaryRow>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<CrewListRow>(e =>
        {
            e.HasNoKey().ToView(null);
            e.Property(p => p.RankName).HasColumnName("Rank Name");
            e.Property(p => p.CrewMemberDisplayId).HasColumnName("Crew Member ID");
            e.Property(p => p.FirstName).HasColumnName("First Name");
            e.Property(p => p.LastName).HasColumnName("Last Name");
        });

        modelBuilder.Entity<ShipSummaryRow>(e => e.HasNoKey().ToView(null));
        modelBuilder.Entity<ShipDetailRow>(e => e.HasNoKey().ToView(null));
        modelBuilder.Entity<UserSummaryRow>(e => e.HasNoKey().ToView(null));
        modelBuilder.Entity<UserDetailRow>(e => e.HasNoKey().ToView(null));
        modelBuilder.Entity<AssignedShipRow>(e => e.HasNoKey().ToView(null));

        modelBuilder.Entity<FinancialReportDetailRow>(e =>
        {
            e.HasNoKey().ToView(null);
            e.Property(p => p.AccountDescription).HasColumnName("COA Description");
            e.Property(p => p.AccountNumber).HasColumnName("Account Number");
            e.Property(p => p.Actual).HasColumnName("Actual").HasPrecision(19, 4);
            e.Property(p => p.Budget).HasColumnName("Budget").HasPrecision(19, 4);
            e.Property(p => p.Variance).HasColumnName("Variance").HasPrecision(19, 4);
            e.Property(p => p.ActualYtd).HasColumnName("Actual YTD").HasPrecision(19, 4);
            e.Property(p => p.BudgetYtd).HasColumnName("Budget YTD").HasPrecision(19, 4);
            e.Property(p => p.VarianceYtd).HasColumnName("Variance YTD").HasPrecision(19, 4);
        });

        modelBuilder.Entity<FinancialReportSummaryRow>(e =>
        {
            e.HasNoKey().ToView(null);
            e.Property(p => p.AccountDescription).HasColumnName("COA Description");
            e.Property(p => p.AccountNumber).HasColumnName("Account Number");
            e.Property(p => p.Actual).HasColumnName("Actual").HasPrecision(19, 4);
            e.Property(p => p.Budget).HasColumnName("Budget").HasPrecision(19, 4);
            e.Property(p => p.Variance).HasColumnName("Variance").HasPrecision(19, 4);
            e.Property(p => p.ActualYtd).HasColumnName("Actual YTD").HasPrecision(19, 4);
            e.Property(p => p.BudgetYtd).HasColumnName("Budget YTD").HasPrecision(19, 4);
            e.Property(p => p.VarianceYtd).HasColumnName("Variance YTD").HasPrecision(19, 4);
        });
    }
}
