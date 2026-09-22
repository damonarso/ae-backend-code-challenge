using Ae.Maritime.Application.Abstractions;

namespace Ae.Maritime.Api.Middleware;

public sealed class HttpContextCurrentUser : ICurrentUser
{
    private readonly IHttpContextAccessor _accessor;

    public HttpContextCurrentUser(IHttpContextAccessor accessor) => _accessor = accessor;

    public string Name
    {
        get
        {
            var identity = _accessor.HttpContext?.User?.Identity;
            return identity?.IsAuthenticated == true && !string.IsNullOrWhiteSpace(identity.Name)
                ? identity.Name
                : "api";
        }
    }
}
