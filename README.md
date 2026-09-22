# AE Maritime Crew and Finance API

ASP.NET Core 8 Web API over SQL Server. All data access goes through stored
procedures; EF Core is used to execute them and materialise their result sets.

## Running it

1. Create an empty database, then run the SQL scripts in order:

   ```
   01_schema.sql
   02_procedures_common.sql
   03_finance.sql
   04_seed_data.sql
   ```
   The 01_schema.sql already created user for the app to login

2. Point `ConnectionStrings:MaritimeDb` at it

3. Run:

   ```
   dotnet run --project src/Ae.Maritime
   ```

4. Endpoint Tests:
   Run the endpoints provided in Ae.Maritime.Http

5. Unit Tests:

   ```
   dotnet test
   ```
## Endpoints

| Method | Route | Purpose |
|---|---|---|
| GET | `/api/ships` | Paginated ship list, filter by status, search code or name |
| GET | `/api/ships/{shipId}` | One ship with its fiscal year detail |
| POST | `/api/ships` | Create a ship |
| GET | `/api/ships/{shipId}/crew` | Crew onboard or relief due; paginated, sortable, searchable |
| GET | `/api/ships/{shipId}/financial-report/detail` | Full COA with period and YTD figures |
| GET | `/api/ships/{shipId}/financial-report/summary` | Parent-account roll-up |
| GET | `/api/users` | Paginated user list |
| GET | `/api/users/{userId}` | One user |
| POST | `/api/users` | Create a user |
| GET | `/api/users/{userId}/ships` | Ships assigned to a user |
| PUT | `/api/users/{userId}/ships/{shipId}` | Assign a ship (idempotent) |
| DELETE | `/api/users/{userId}/ships/{shipId}` | Unassign a ship |

### Worked example: the fiscal year boundary

SHIP02 runs an April-March fiscal year (`0403`). Asking for February 2025:

```
GET /api/ships/2/financial-report/detail?period=2025-02
```

returns `"fiscalYearStartCode": "2024-04"`, and every `actualYtd` and
`budgetYtd` sums April 2024 through February 2025 inclusive. A ship on the
calendar year asked for the same period returns `2025-01`.

### Null versus zero

`actual: null` means nothing was posted to that account for the period.
`actual: 0` means a posting of zero exists. The API never collapses one into
the other, and null properties are serialised rather than omitted.

## Project layout

One project. The layers are folders, and the namespaces follow them.

```
src/Ae.Maritime/
  Domain/           enums, value objects, domain exceptions
  Application/      DTOs, validators, service interfaces and implementations
  Infrastructure/   EF Core DbContext, result rows, repositories, SQL error mapping
  Api/              controllers, exception middleware
  Program.cs        composition root
tests/Ae.Maritime.Tests/
                    service, validator and architecture tests; no database required
```

Dependencies point inward: `Api` -> `Application` -> `Domain`, with
`Infrastructure` implementing the interfaces `Application` declares. A single
assembly cannot enforce that the way project references did, so
`ArchitectureTests` asserts it against the compiled IL and fails the build if a
layer reaches the wrong way. `src/Ae.Maritime/ARCHITECTURE.md` explains the
trade in full.

See `DESIGN.md` for why it is built this way.
