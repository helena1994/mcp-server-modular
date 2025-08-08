# ADR-0001: Refresh Token Strategy

## Status
Accepted

## Konteks
Sistem membutuhkan mekanisme session berkelanjutan tanpa membuat access token berdurasi panjang.

## Keputusan
- Menggunakan JWT access (15m) + JWT refresh (7d default).
- Refresh token disimpan hashed di DB (tabel RefreshToken).
- Rotating refresh token: setiap refresh menghasilkan pasangan baru & menandai lama revoked.
- Refresh token JWT payload memuat flag `rt: true` untuk pembedaan.
- Revoke manual tersedia (logout).

## Konsekuensi
+ Keamanan lebih baik (token dicuri dapat segera invalid setelah rotasi).
+ Perlu penanganan race (opsional fase lanjut).
+ Storage tambahan (tabel refresh_tokens).

## Alternatif Dipertimbangkan
- Stateless only refresh (tanpa DB) -> sulit revoke targeted.
- Opaque token + Redis -> menambah infrastruktur (ditunda).