# Backend Foundation Template (TypeScript + Fastify + Clean Architecture)

## Ringkasan
Kerangka backend modular untuk akselerasi pengembangan layanan API yang scalable dan maintainable.

## Fitur Awal
- Struktur Clean Architecture (domain / application / infrastructure / interface layer)
- Fastify bootstrap + global error handler
- Validasi environment (zod)
- Auth (rangka awal) – placeholder
- Health & version endpoint
- Prisma + PostgreSQL schema awal (users, roles, permissions, refresh_tokens)
- Linting, formatting, commit lint
- Testing (Jest) baseline
- CI pipeline (lint, test, build, security audit)
- Docker multi-stage + docker-compose (app + postgres)

## Platform & DApp Links
| Komponen | URL (placeholder) |
|---------|--------------------|
| Platform (web utama) | https://platform.example.com |
| DApp Frontend | https://app.example.com |
| API Base | http://localhost:3000 |

Update file `docs/DAPP-PLATFORM-LINKS.md` dan variabel env bila URL final sudah tersedia.

## Struktur Direktori
```
src/
  app/
    bootstrap/
      server.ts
    config/
      env.ts
    http/
      controllers/
        health.controller.ts
      routes/
        index.ts
      middlewares/
        error-handler.ts
        request-context.ts
    utils/
      logger.ts
  domain/
    user/
      user.entity.ts
      user.types.ts
    auth/
      tokens.ts
    role/
      role.entity.ts
    shared/
      base.entity.ts
      errors.ts
  application/
    use-cases/
      user/
        register-user.usecase.ts
        login-user.usecase.ts
    dto/
      user.dto.ts
    services/
      hashing/
        hashing.port.ts
      token/
        token.port.ts
  infrastructure/
    db/
      prisma-client.ts
    repositories/
      user.repository.prisma.ts
    security/
      argon2-hashing.service.ts
      jwt-token.service.ts
    logging/
      pino-logger.factory.ts
    telemetry/
      tracing.init.ts (placeholder)
  interfaces/
    repositories/
      user.repository.port.ts
    services/
      hashing.service.port.ts
      token.service.port.ts
tests/
  unit/
  integration/
prisma/
  schema.prisma
```

## Environment
Lihat `.env.example`.

## Jalankan Lokal
```
cp .env.example .env
docker compose up -d db
npm install
npx prisma migrate dev
npm run dev
```

## Skrip
Lihat `package.json` bagian scripts.

## Quality
- ESLint + Prettier
- Commitlint (Conventional Commits)
- Jest (unit + integration)
- Coverage target (nanti fase 2) 85% domain/application

## Roadmap
Lihat `docs/ROADMAP.md`.

## Lisensi
MIT.