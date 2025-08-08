# DApp & Platform Links

Dokumen ini memusatkan referensi URL untuk berbagai komponen.

| Komponen | Deskripsi | URL (placeholder) | Env Var (kalau relevan) |
|----------|-----------|-------------------|-------------------------|
| Platform | Portal utama / marketing / dashboard global | https://platform.example.com | PLATFORM_BASE_URL |
| DApp Frontend | Aplikasi terotentikasi (UI) | https://app.example.com | DAPP_BASE_URL |
| API | Backend REST API | http://localhost:3000 | API_BASE_URL (opsional) |

## Instruksi Penyesuaian
1. Ganti placeholder dengan domain final saat tersedia.
2. Perbarui `.env` lokal dan secret di pipeline.
3. Tambahkan juga di dokumentasi eksternal (misal wiki atau portal dev) agar konsisten.

## Catatan Domain
- Gunakan TLS (HTTPS) untuk semua domain publik.
- Pertimbangkan subdomain versi staging: `staging.platform.example.com`, `staging.app.example.com`.