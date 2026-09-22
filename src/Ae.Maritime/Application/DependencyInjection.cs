using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Application.Crew;
using Ae.Maritime.Application.Finance;
using Ae.Maritime.Application.Fleet;
using Ae.Maritime.Application.Identity;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;

namespace Ae.Maritime.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<ICrewService, CrewService>();
        services.AddScoped<IShipService, ShipService>();
        services.AddScoped<IUserService, UserService>();
        services.AddScoped<IFinanceService, FinanceService>();

        services.AddValidatorsFromAssemblyContaining<CrewListQueryValidator>(
            lifetime: ServiceLifetime.Singleton);

        return services;
    }
}
