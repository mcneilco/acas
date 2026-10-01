# ACAS Docker Compose Environment

## Overview

This is the main orchestration repository for running ACAS locally using Docker Compose. It brings together all ACAS services: frontend, backend, database, and R services.

## Services

The `docker compose.yml` defines four services:

| Service | Port(s) | Description |
|---------|---------|-------------|
| **acas** | 3000, 3001, 5858 | Frontend Node.js application and API gateway |
| **roo** | 8080, 8000 | Java backend (Tomcat) + remote debugging |
| **db** | 5432 | PostgreSQL database |
| **rservices** | 1080 | R statistical computing services |

## Configuration

### Environment Variables

The `.env` file controls image tags:

```bash
# .env
ACAS_TAG=master
```

**Image naming convention:**
- `acas`: `mcneilco/acas-oss:${ACAS_TAG}`
- `roo`: `mcneilco/acas-roo-server-oss:${ACAS_TAG}-indigo`
- `rservices`: `mcneilco/racas-oss:${ACAS_TAG}`
- `db`: `mcneilco/acas-postgres:release-2023.3.x` (pinned version)

## Using a Locally Built Roo Image

When you've built a local roo-server image (see [CLAUDE.md in acas-roo-server repo](https://github.com/mcneilco/acas-roo-server/blob/master/CLAUDE.md)), you need to update docker compose.yml to use it.

### Steps:

1. **Build the roo image** (from acas-roo-server directory):
   ```bash
   cd ../acas-roo-server
   docker build --build-arg CHEMISTRY_PACKAGE=indigo -t mcneilco/acas-roo-server-oss:dev -f Dockerfile-multistage .
   ```

   **IMPORTANT**: Must use `--build-arg CHEMISTRY_PACKAGE=indigo` to match the production image configuration.

2. **Edit `docker compose.yml`** to point to your local image:
   ```yaml
   roo:
     image: mcneilco/acas-roo-server-oss:dev  # Changed from ${ACAS_TAG}-indigo
     # ... rest of config stays the same
   ```

3. **Restart services**:
   ```bash
   docker compose down
   docker compose up -d
   ```

4. **Verify services are running**:
   ```bash
   docker compose ps
   docker compose logs -f roo  # Watch roo logs
   ```

### Alternative: docker compose.override.yml

Instead of editing `docker compose.yml` directly, you can create a `docker compose.override.yml`:

```yaml
# docker compose.override.yml
version: '2'
services:
  roo:
    image: mcneilco/acas-roo-server-oss:dev
```

This file is automatically loaded by docker compose and won't be committed to git (if properly gitignored).

## Starting the Environment

```bash
# Start all services in background
docker compose up -d

# View logs for all services
docker compose logs -f

# View logs for specific service
docker compose logs -f roo

# Check service status
docker compose ps
```

## Stopping the Environment

```bash
# Stop all services (preserves data)
docker compose stop

# Stop and remove containers (preserves volumes)
docker compose down

# Stop and remove containers AND volumes (DESTRUCTIVE - loses all data)
docker compose down -v
```

## Waiting for Services to be Ready

After starting services, it takes time for all services to initialize. The ACAS container waits for the Roo service to be ready before completing its own startup, so you only need to wait for the ACAS API endpoint.

**Wait script** (based on `docker_bob_setup.sh`, waits up to 120 seconds):

```bash
counter=0; wait=120; while ! curl --output /dev/null --silent --head --fail http://localhost:3001/api/authors && [ "$counter" -lt "$wait" ]; do sleep 1; counter=$((counter+1)); done; if [ "$counter" -ge "$wait" ]; then echo "ACAS failed to start"; exit 1; else echo "ACAS started!"; fi
```

## Volumes

Persistent data is stored in named volumes:

- `dbstore`: PostgreSQL database files
- `filestore`: Uploaded files and private uploads
- `logs`: Application logs

**View volumes:**
```bash
docker volume ls | grep acas
```

## Common Workflows

### After Code Changes to Roo Server

1. Rebuild roo Docker image (see acas-roo-server/CLAUDE.md)
2. Update docker compose.yml to use new image tag
3. Restart roo service:
   ```bash
   docker compose restart roo
   ```

### After Code Changes to Frontend (acas)

The acas service mounts local code as a volume and has hot-reload enabled, so changes are reflected automatically without restart.

### Clean Start (Fresh Database)

**WARNING**: This deletes all data!

```bash
docker compose down -v
docker compose up -d
```

## Testing

After starting services, run tests from the acasclient repository:
- See [CLAUDE.md in acasclient repo](https://github.com/mcneilco/acasclient/blob/main/CLAUDE.md) for testing workflow

## Troubleshooting

### Roo service won't start

1. Check if database is ready:
   ```bash
   docker compose logs db
   ```

2. Check roo logs for errors:
   ```bash
   docker compose logs roo | grep -i error
   ```

3. Ensure ports aren't already in use:
   ```bash
   lsof -i :8080
   lsof -i :5432
   ```

### Services are slow

1. Check Docker resource limits (memory/CPU)
2. Check for high disk usage in volumes
3. Restart Docker daemon

## Related Documentation

- **Roo Server Build**: [CLAUDE.md in acas-roo-server repo](https://github.com/mcneilco/acas-roo-server/blob/master/CLAUDE.md)
- **Testing**: [CLAUDE.md in acasclient repo](https://github.com/mcneilco/acasclient/blob/main/CLAUDE.md)
