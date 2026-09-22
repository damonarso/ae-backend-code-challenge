# Folder layout

One project, four layers as folders. Namespaces follow the folders, so
`Application/Crew/CrewService.cs` is `Ae.Maritime.Application.Crew.CrewService`
exactly as it was when each layer was its own assembly.

```
Domain/          enums, value objects, domain exceptions
Application/     DTOs, validators, service interfaces, service implementations
Infrastructure/  EF Core DbContext, result rows, repositories, SQL error mapping
Api/             controllers, middleware
Program.cs       composition root
```

## The dependency rule

Dependencies point inward only:

```
Api  ->  Application  ->  Domain
             ^
Infrastructure ------------+
```

- `Domain` references nothing in the other folders.
- `Application` references `Domain` only.
- `Infrastructure` implements interfaces declared in `Application/Abstractions`.
- `Api` depends on `Application`; it touches `Infrastructure` in exactly one
  place, the `AddInfrastructure` call in `Program.cs`.

## What collapsing to one project cost

With four projects the compiler enforced that rule: a `using` from Domain into
Infrastructure would not build, because the project reference did not exist.
In a single assembly that check is gone. Nothing stops a controller from
injecting `MaritimeDbContext` directly and bypassing the repository.

Three things hold the line instead:

1. **`internal` on the Infrastructure types.** `MaritimeDbContext` is public
   because `AddDbContext` needs it, but the repositories, the result rows and
   the error translator are `internal`, so they can only be reached through the
   `Application/Abstractions` interfaces. That is convention plus a small
   amount of real enforcement.

2. **An architecture test.** `tests/Ae.Maritime.Tests/ArchitectureTests.cs`
   asserts the dependency direction by inspecting the compiled IL, and fails
   the build if a layer reaches the wrong way. It replaces what the project
   references used to guarantee.

3. **One composition root.** All wiring happens in `Program.cs` via the two
   `Add*` extension methods, so an accidental dependency has nowhere to be
   registered quietly.

The trade is real and worth stating plainly: a single project is simpler to
clone, build and read, which matters for a code challenge, and the layering
becomes a discipline backed by a test rather than a compiler guarantee. If this
grew into a system where several teams touched it, splitting the assemblies
back out would be the first thing to do — and because the namespaces already
match the folders, that split is a mechanical move rather than a rewrite.
