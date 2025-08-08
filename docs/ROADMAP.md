# ROADMAP

## Fase 1: Foundation
- Bootstrap Fastify + error handler
- Env validation (zod)
- Prisma + migrasi awal
- User register + login + refresh token (baseline)
- Health endpoint
- Logging dasar (pino)
- CI (lint, test, build)

## Fase 2: Core & Observability
- Roles & permissions + guard
- Metrics (Prometheus)
- Tracing OpenTelemetry
- Coverage ≥85% domain/application
- Audit trail baseline
- Security scanning (image + deps)

## Fase 3: Hardening & Scale
- Rate limiting adaptif
- Caching (Redis) selective
- Load testing baseline (k6)
- Helm chart (opsional)
- semantic-release + changelog
- SLO (latency, error rate)

## Backlog Kandidat
- Multi-tenant
- API keys
- Webhooks
- Event bus (Kafka/NATS)
- GraphQL gateway

## Metrik
- Dev setup < 15m
- Coverage domain ≥85%
- P99 auth <250ms baseline
- Pipeline flakiness <5%

## Risiko & Mitigasi
| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Scope creep | Delay | Freeze per fase |
| Flaky tests | Distrust | Quarantine & fix <24h |
| Security debt | Vulnerability | Scan & policy |
| Over-engineering | Lambat deliver | YAGNI, review arsitektur |