# BattleTech API (mul-api)

A public, read-mostly REST API for BattleTech tabletop-game reference data
(weapons, equipment, ammunition, factions, eras, rules, tech bases, and tech
levels), sourced from the [MegaMek](https://github.com/MegaMek) project's
data. It also hosts a small "server announce" registry that running MegaMek
game servers use to advertise themselves to players, and an internal
account system (registration, email confirmation, password reset) backing
authenticated write operations.

Built with [Vapor](https://vapor.codes) (server-side Swift) and
[Fluent](https://docs.vapor.codes/fluent/overview/) on PostgreSQL.

- Production: <https://api.quartermaster-command.services>
- Staging: <https://api.battletech.dev>

## What this API provides

- **`/battletech/*`** — read-only, paginated access to `ammo`, `equipment`,
  `era`, `faction`, `munitiontype`, `rules`, `techbase`, `techlevel`, and
  `weapon` reference data. Each resource also exposes a CSV mass-import
  endpoint (`POST /battletech/<resource>/import`) that queues rows as
  background jobs (see `Sources/App/Jobs`) rather than importing inline.
- **`/servers`** and **`/servers/announce`** — the original endpoints a
  running MegaMek game server calls to list itself (and its player count,
  password state, version, etc.) in the public server directory.
- **`/api/v1/servers`** — the versioned successor to the endpoints above;
  the API is mid-transition from the unversioned `/servers` routes to this
  `/api/v1` structure (see `Sources/App/Controllers/ServersController.swift`).
- **Accounts** — `Security.User` and related token models support email
  confirmation and forgot-password flows (delivered via SendGrid) for
  future authenticated endpoints.

## Requirements

- **Swift 6.3** toolchain, matching `Package.swift` and the `Dockerfile`.
  Install via [swift.org](https://www.swift.org/install/) or
  [Swiftly](https://www.swift.org/swiftly/), or use the `swift:6.3-noble`
  Docker image if you don't want to install Swift locally.
- **PostgreSQL** (developed against `postgres:latest` / `postgres:18-alpine`).
- **Docker** and **Docker Compose**, optional, for a containerized
  dev/prod-like setup.
- A **SendGrid** account and API key — optional for local development
  (account emails will just fail to send without it), required in any
  environment that needs to actually deliver confirmation/reset emails.

## Local development

### 1. Start a database

```sh
docker run --name api-battletech \
  -e POSTGRES_DB=api-battletech \
  -e POSTGRES_USER=vapor \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 -d postgres:latest
```

### 2. Build, migrate, and run

```sh
swift build
swift run App migrate -y
swift run App serve
```

With no environment variables set, the app connects to Postgres at
`localhost:5432` using the `vapor` / `password` / `api-battletech`
credentials above — see [Configuration](#configuration) for the full list
of variables and their defaults.

### Running with Docker Compose (alternative)

`docker-compose.yml` bundles the app, a Postgres database, and one-off
migration/revert runners:

```sh
docker-compose build              # build the app image
docker-compose up db               # start just the database
docker-compose up app              # start the app (depends on db)
docker-compose run migrate         # run pending migrations
docker-compose run revert          # revert the last migration batch
docker-compose down                # stop everything (add -v to also wipe the db volume)
```

## Testing

Use a second, disposable Postgres instance on a different port so it can
run alongside your dev database:

```sh
docker run --name api-battletech-test \
  -e POSTGRES_DB=api-battletech \
  -e POSTGRES_USER=vapor \
  -e POSTGRES_PASSWORD=password \
  -p 5433:5432 -d postgres:latest
```

```sh
swift test --enable-code-coverage
```

CI (`.github/workflows/ci.yml`) runs the same command and additionally
publishes a coverage summary to the workflow run's job summary, plus an
`lcov` report as a build artifact. To see a coverage summary locally, run
the same `llvm-cov` step CI uses:

```sh
BIN_PATH="$(swift build --show-bin-path)"
XCTEST_PATH="$(find "$BIN_PATH" -name '*.xctest')"
llvm-cov report "$XCTEST_PATH" \
  --instr-profile=".build/debug/codecov/default.profdata" \
  --ignore-filename-regex="(\.build|TestUtils|Tests)"
```

## Documentation

Public types and methods are documented with Swift-DocC-compatible `///`
comments throughout `Sources/App`. Generate browsable API documentation
locally with:

```sh
swift package generate-documentation --target App
```

or, in Xcode, **Product ▸ Build Documentation**. On every push to `develop`,
`.github/workflows/docs.yml` regenerates this documentation and publishes it
to GitHub Pages (requires the repo's **Settings ▸ Pages ▸ Source** to be set
to **GitHub Actions**, once, by a repo admin).

## Configuration

Runtime configuration is read entirely from environment variables (see
`Sources/App/Settings/Database.swift`):

| Variable | Purpose | Default |
| - | - | - |
| `DATABASE_HOST` | Postgres hostname | `localhost` |
| `DATABASE_PORT` | Postgres port | `5432` |
| `DATABASE_USERNAME` | Postgres username | `vapor` |
| `DATABASE_PASSWORD` | Postgres password | `password` |
| `DATABASE_NAME` | Postgres database name | `api-battletech` |
| `SENDGRID_API_KEY` | SendGrid API key used to send confirmation/password-reset emails | *(none — email sending fails without it)* |
| `LOG_LEVEL` | Vapor log verbosity (used by `docker-compose.yml`) | `debug` |

## Deployment

Deploys run via GitHub Actions (`.github/workflows/ci.yml` and
`deploy.yml`): pushing to `develop` builds and pushes a container image to
`ghcr.io/megamek/api-data` and automatically deploys it to staging; pushing
to `main` builds the production image, but the production deploy itself is
a manual `workflow_dispatch` gated to the `main` branch. Both deploy jobs
run an Ansible playbook (`ansible/staging.yml` / `ansible/production.yml`)
over SSH against the target host to pull the new image and restart the
service.

Required GitHub Actions secrets for deployment:

| Secret | Used for |
| - | - |
| `DEPLOY_SSH_PRIVATE_KEY` | SSH key for the `deploy` user on the staging/production hosts |
| `GHCR_READ_TOKEN` | Lets the deploy hosts `docker pull` from `ghcr.io` |
| `STAGING_DATABASE_HOST`, `_NAME`, `_USERNAME`, `_PASSWORD` | Postgres connection info for the staging container |
| `PRODUCTION_DATABASE_HOST`, `_NAME`, `_USERNAME`, `_PASSWORD` | Postgres connection info for the production container |
| `SENDGRID_API_KEY` | Passed through to both environments' containers |
