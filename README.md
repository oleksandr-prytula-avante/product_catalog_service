# Product Catalog Service

A Go-based backend service for managing products and pricing with Google Cloud Spanner, built following Domain-Driven Design (DDD) and Clean Architecture principles.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Database Schema](#database-schema)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [Docker Services](#docker-services)
- [Database Migrations](#database-migrations)
- [Development](#development)
- [Building for Production](#building-for-production)

---

## Overview

The Product Catalog Service manages products and their pricing data. It provides:

- **Product Management** — create, update, activate/deactivate, and archive (soft-delete) products
- **Pricing Rules** — apply percentage-based discounts with start/end dates; precise decimal arithmetic via rational number storage (`numerator / denominator`)
- **Product Queries** — get product by ID with effective price, list active products with pagination, filter by category
- **Reliable Event Publishing** — transactional outbox pattern ensures events are published atomically with data mutations

---

## Architecture

The project follows **Clean Architecture** with **CQRS**:

```
Transport (gRPC)
    └── Use Cases (Commands / Queries)
            └── Domain (Aggregates, Value Objects, Domain Events)
                    └── Repository (Spanner via CommitPlan)
```

- **Commands** go through domain aggregates and are committed atomically via `github.com/Vektor-AI/commitplan` with its Spanner driver
- **Queries** may bypass the domain layer for performance
- **Domain layer** is free of infrastructure dependencies — no DB libraries, no `context`, no proto imports
- **Money** is stored as `INT64` numerator + `INT64` denominator, computed with `math/big.Rat` for precision
- **Outbox pattern** guarantees at-least-once event delivery by writing events in the same Spanner transaction as the mutation

---

## Technology Stack

| Concern | Technology |
|---|---|
| Language | Go 1.26+ |
| Database | Google Cloud Spanner |
| Local DB | Spanner Emulator (`gcr.io/cloud-spanner-emulator/emulator`) |
| Transport | gRPC + Protocol Buffers |
| Transactions | `github.com/Vektor-AI/commitplan` (Spanner driver) |
| Migrations | [Wrench](https://github.com/cloudspannerecosystem/wrench) |
| Hot Reload | [Air](https://github.com/air-verse/air) |
| Containerization | Docker Compose |

---

## Project Structure

```
product_catalog_service/
├── main.go
├── go.mod
├── air.toml
├── docker-compose.yml
├── test_task.md
├── db/
│   ├── schema.sql
│   ├── wrench.hcl
│   └── migrations/
├── scripts/
│   ├── log.sh
│   ├── spanner-init.sh
│   └── wrench-migrate.sh
├── docker/
│   ├── app.build.Dockerfile
│   ├── app.dev.Dockerfile
│   └── atlas.Dockerfile
├── tmp/
└── .env
```

---

## Database Schema

### `products`

| Column | Type | Description |
|---|---|---|
| `product_id` | `STRING(36)` | UUID primary key |
| `name` | `STRING(255)` | Product name |
| `description` | `STRING(MAX)` | Optional description |
| `category` | `STRING(100)` | Product category |
| `base_price_numerator` | `INT64` | Price numerator (rational storage) |
| `base_price_denominator` | `INT64` | Price denominator (rational storage) |
| `discount_percent` | `NUMERIC` | Active discount percentage |
| `discount_start_date` | `TIMESTAMP` | Discount validity start |
| `discount_end_date` | `TIMESTAMP` | Discount validity end |
| `status` | `STRING(20)` | `active`, `inactive`, or `archived` |
| `created_at` | `TIMESTAMP` | Record creation time |
| `updated_at` | `TIMESTAMP` | Last update time |
| `archived_at` | `TIMESTAMP` | Soft-delete timestamp |

### `outbox_events`

| Column | Type | Description |
|---|---|---|
| `event_id` | `STRING(36)` | UUID primary key |
| `event_type` | `STRING(100)` | Event type identifier |
| `aggregate_id` | `STRING(36)` | ID of the affected aggregate |
| `payload` | `JSON` | Event payload |
| `status` | `STRING(20)` | `pending` or `processed` |
| `created_at` | `TIMESTAMP` | When the event was created |
| `processed_at` | `TIMESTAMP` | When the event was delivered |

**Indexes:**
- `idx_outbox_status` on `outbox_events(status, created_at)`
- `idx_products_category` on `products(category, status)`

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/) v2.20+
- Go 1.26+ (for local development without Docker)

---

## Getting Started

**1. Clone the repository**

```sh
git clone https://github.com/oleksandr-prytula-avante/product_catalog_service.git
cd product_catalog_service
```

**2. Create your `.env` file**

```sh
# Create manually (example values are listed below)
```

**3. Start the full development stack**

```sh
docker compose --profile dev up --build
```

This will start, in order:
1. `spanner-emulator` — Cloud Spanner emulator
2. `spanner-init` — creates the Spanner instance and database via `gcloud`
3. `wrench-migrate` — applies migration files from `db/migrations`
4. `app-dev` — the Go service with Air hot-reload

The service will be available at `localhost:${APP_PORT}`.

---

## Environment Variables

Create a `.env` file in the project root:

```dotenv
APP_PORT=8080

# Spanner
SPANNER_PROJECT_ID=product-catalog-project
SPANNER_INSTANCE_ID=main
SPANNER_DATABASE_ID=product-catalog
SPANNER_EMULATOR_HOST=spanner-emulator:9010
```

| Variable | Description |
|---|---|
| `APP_PORT` | HTTP/gRPC port the service listens on |
| `SPANNER_PROJECT_ID` | GCP project ID (any value works for the emulator) |
| `SPANNER_INSTANCE_ID` | Spanner instance name |
| `SPANNER_DATABASE_ID` | Spanner database name |
| `SPANNER_EMULATOR_HOST` | Emulator address used by the Go Spanner client |

---

## Docker Services

| Service | Image / Dockerfile | Profile | Description |
|---|---|---|---|
| `spanner-emulator` | `gcr.io/cloud-spanner-emulator/emulator` | always | Cloud Spanner local emulator |
| `spanner-init` | `google/cloud-sdk:slim` | always | Creates Spanner instance and database |
| `wrench-migrate` | `ghcr.io/cloudspannerecosystem/wrench:1.13.2` | always | Runs Spanner migrations from `db/migrations` |
| `app-dev` | `docker/app.dev.Dockerfile` | `dev` | Go service with Air hot-reload |
| `app-build` | `docker/app.build.Dockerfile` | `build` | Compiled production binary |

**Startup dependency chain:**

```
spanner-emulator
    └── spanner-init  (waits for emulator HTTP port 9020)
            └── wrench-migrate  (waits for spanner-init to start)
                    └── app-dev / app-build
```

---

## Database Migrations

Migrations are applied by [wrench](https://github.com/cloudspannerecosystem/wrench) from migration files in `db/migrations`.

**How it works:**

1. `spanner-init` ensures the instance and database exist.
2. `wrench-migrate` runs `wrench migrate up --directory ./db`.
3. Wrench reads migration files from `db/migrations`.

**To apply migrations manually:**

```sh
docker compose up wrench-migrate --no-deps
```

---

## Development

The `app-dev` profile uses [Air](https://github.com/air-verse/air) for hot-reload. Any change to a `.go` file triggers an automatic rebuild and restart.

```sh
# Start dev stack
docker compose --profile dev up --build

# View logs for a specific service
docker compose logs -f app-dev
docker compose logs -f wrench-migrate

# Rebuild a single service
docker compose --profile dev up --build app-dev
```

Air is configured in [`air.toml`](air.toml) — it builds to `tmp/app` and watches all `.go` files.

---

## Building for Production

```sh
docker compose --profile build up --build
```

The `app-build` service uses a multi-stage-style build (`docker/app.build.Dockerfile`) that compiles the binary with `CGO_ENABLED=0` and `-trimpath` for a minimal, portable binary.
