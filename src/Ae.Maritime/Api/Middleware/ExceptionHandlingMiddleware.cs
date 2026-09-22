#pragma warning disable CA1873
using System.Text.Json;
using Ae.Maritime.Domain.Common;
using Microsoft.AspNetCore.Mvc;

namespace Ae.Maritime.Api.Middleware;

public sealed partial class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;
    private readonly IHostEnvironment _environment;

    public ExceptionHandlingMiddleware(
        RequestDelegate next,
        ILogger<ExceptionHandlingMiddleware> logger,
        IHostEnvironment environment)
    {
        _next = next;
        _logger = logger;
        _environment = environment;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (OperationCanceledException) when (context.RequestAborted.IsCancellationRequested)
        {
            LogRequestCancelled(context.Request.Path);
            context.Response.StatusCode = 499;
        }
        catch (Exception ex)
        {
            await WriteProblemAsync(context, ex);
        }
    }

    private async Task WriteProblemAsync(HttpContext context, Exception exception)
    {
        if (context.Response.HasStarted)
        {
            LogExceptionAfterResponseStarted(exception);
            return;
        }

        ProblemDetails problem;

        switch (exception)
        {
            case InputValidationException validation:
                LogValidationFailed(
                    string.Join("; ", validation.Errors.Select(e => $"{e.Key}: {string.Join(", ", e.Value)}")));

                problem = new ValidationProblemDetails(
                    validation.Errors.ToDictionary(e => e.Key, e => e.Value))
                {
                    Status = StatusCodes.Status400BadRequest,
                    Title = "One or more validation errors occurred.",
                    Type = "https://tools.ietf.org/html/rfc9110#section-15.5.1"
                };
                break;

            case NotFoundException notFound:
                LogNotFound(notFound.Message);
                problem = Problem(StatusCodes.Status404NotFound, "Resource not found", notFound.Message);
                break;

            case ConflictException conflict:
                LogConflict(conflict.Message);
                problem = Problem(StatusCodes.Status409Conflict, "Conflict", conflict.Message);
                break;

            case BusinessRuleException rule:
                LogBusinessRuleViolated(rule.Message);
                problem = Problem(StatusCodes.Status422UnprocessableEntity,
                                  "Business rule violation", rule.Message);
                break;

            default:
                LogUnhandledException(exception, context.Request.Path);
                problem = Problem(
                    StatusCodes.Status500InternalServerError,
                    "An unexpected error occurred",
                    _environment.IsDevelopment()
                        ? exception.ToString()
                        : "An unexpected error occurred while processing the request.");
                break;
        }

        problem.Extensions["traceId"] = context.TraceIdentifier;
        problem.Instance = context.Request.Path;

        context.Response.StatusCode = problem.Status ?? StatusCodes.Status500InternalServerError;
        context.Response.ContentType = "application/problem+json";

        await context.Response.WriteAsync(
            JsonSerializer.Serialize(problem, problem.GetType(), JsonOptions));
    }

    private static ProblemDetails Problem(int status, string title, string detail) =>
        new() { Status = status, Title = title, Detail = detail };

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull
    };

    [LoggerMessage(Level = LogLevel.Information, Message = "Request cancelled by the client: {Path}")]
    private partial void LogRequestCancelled(PathString path);

    [LoggerMessage(Level = LogLevel.Error, Message = "Exception after the response had started.")]
    private partial void LogExceptionAfterResponseStarted(Exception exception);

    [LoggerMessage(Level = LogLevel.Information, Message = "Validation failed: {Errors}")]
    private partial void LogValidationFailed(string errors);

    [LoggerMessage(Level = LogLevel.Information, Message = "Not found: {Message}")]
    private partial void LogNotFound(string message);

    [LoggerMessage(Level = LogLevel.Information, Message = "Conflict: {Message}")]
    private partial void LogConflict(string message);

    [LoggerMessage(Level = LogLevel.Information, Message = "Business rule violated: {Message}")]
    private partial void LogBusinessRuleViolated(string message);

    [LoggerMessage(Level = LogLevel.Error, Message = "Unhandled exception processing {Path}.")]
    private partial void LogUnhandledException(Exception exception, PathString path);
}

public static class ExceptionHandlingMiddlewareExtensions
{
    public static IApplicationBuilder UseExceptionHandling(this IApplicationBuilder app) =>
        app.UseMiddleware<ExceptionHandlingMiddleware>();
}
