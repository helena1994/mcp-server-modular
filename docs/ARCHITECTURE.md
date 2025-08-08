# Arsitektur Backend (Ringkas)

## Lapisan
- domain: Entity, Value Object, Domain Error.
- application: Use case + port (interface), DTO, service abstraction.
- infrastructure: Implementasi port (repository, security, logging, db).
- app: Framework Fastify (bootstrap, routes, controller, middleware).

## Alur Auth (Login)
1. Controller validasi input (Zod)
2. UseCase (LoginUserUseCase)
3. Repo user -> verifikasi password (hashing service)
4. Token service terbitkan access + refresh
5. Refresh token disimpan hashed di DB (refresh_tokens)
6. Response token pair

## Refresh Flow
- Client kirim refresh token
- Verifikasi signature JWT refresh
- Cocokkan hash di DB + belum revoked + belum expired
- Terbitkan token baru (access + refresh baru), revoke lama (rotasi)

## Keamanan
- Hash password & refresh token (argon2)
- JWT (access pendek, refresh lebih panjang)
- Error mapping terkontrol (DomainError -> HTTP)

## Observability (Fase 2)
- OpenTelemetry tracing
- Metrics (Prometheus)
- Structured log (pino)

## Extensi Lanjut
- Role & Permission guard
- Rate limit adaptif
- Caching selective (Redis)

Lihat juga ROADMAP.md.