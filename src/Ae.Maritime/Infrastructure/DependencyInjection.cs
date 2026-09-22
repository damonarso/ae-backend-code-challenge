using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Infrastructure.Persistence;
using Ae.Maritime.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Ae.Maritime.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("MaritimeDb")
            ?? throw new InvalidOperationException(
                   "Connection string 'MaritimeDb' is not configured.");

        services.AddDbContext<MaritimeDbContext>(options =>
        {
            options.UseSqlServer(connectionString, sql =>
            {
                sql.EnableRetryOnFailure(
                    maxRetryCount: 3,
                    maxRetryDelay: TimeSpan.FromSeconds(5),
                    errorNumbersToAdd: null);

                sql.CommandTimeout(30);
            });

            options.UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking);
        });

        services.AddScoped<ICrewRepository, CrewRepository>();
        services.AddScoped<IShipRepository, ShipRepository>();
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IFinanceRepository, FinanceRepository>();

        return services;
    }
}
