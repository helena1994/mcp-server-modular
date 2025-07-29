# Konfigurasi Server Proxy

Direktori ini berisi file konfigurasi lengkap untuk setup server proxy dengan SOCKS5, Shadowsocks, WireGuard, dan DNS.

## File yang Tersedia

| File | Deskripsi | Tujuan |
|------|-----------|--------|
| `setup-proxy-server.sh` | Script otomatis untuk instalasi dan konfigurasi | `/` (jalankan dari direktori ini) |
| `danted.conf` | Konfigurasi Dante SOCKS5 proxy | `/etc/danted.conf` |
| `shadowsocks-config.json` | Konfigurasi Shadowsocks server | `/etc/shadowsocks-libev/config.json` |
| `wg0.conf` | Konfigurasi WireGuard VPN tunnel | `/etc/wireguard/wg0.conf` |
| `resolv.conf` | Konfigurasi DNS dengan Cloudflare | `/etc/resolv.conf` |
| `panduan-setup.md` | Panduan lengkap setup dan troubleshooting | Dokumentasi |

## Instalasi Cepat

```bash
# Clone repository
git clone https://github.com/helena1994/mcp-server-modular.git
cd mcp-server-modular/config/proxy

# Jalankan script setup
sudo chmod +x setup-proxy-server.sh
sudo ./setup-proxy-server.sh
```

## Komponen yang Diinstall

### 1. **SOCKS5 Proxy (Dante)**
- Port: 1080
- Protokol: SOCKS5
- Autentikasi: Opsional

### 2. **Shadowsocks**
- Port: 8388
- Enkripsi: AES-256-GCM
- Password: Konfigurasi manual diperlukan

### 3. **WireGuard VPN**
- Port: 51820 (UDP)
- Network: 10.8.0.0/24
- DNS: Cloudflare (1.1.1.1)

### 4. **DNS Configuration**
- Primary: 1.1.1.1 (Cloudflare)
- Secondary: 1.0.0.1 (Cloudflare)
- IPv6: Didukung

## Keamanan

⚠️ **PENTING: Sebelum menggunakan di produksi:**

1. **Ganti semua password default**
2. **Generate kunci WireGuard yang baru**
3. **Konfigurasi firewall dengan benar**
4. **Enable autentikasi untuk SOCKS5**
5. **Monitor log secara berkala**

## Quick Start

1. **Setup semua komponen:**
   ```bash
   sudo ./setup-proxy-server.sh
   # Pilih opsi 1 (Install semua)
   ```

2. **Cek status layanan:**
   ```bash
   sudo ./setup-proxy-server.sh
   # Pilih opsi 6 (Status layanan)
   ```

3. **Lihat informasi koneksi:**
   ```bash
   sudo ./setup-proxy-server.sh
   # Pilih opsi 7 (Informasi koneksi)
   ```

## Testing

### Test SOCKS5:
```bash
curl -x socks5://YOUR_SERVER_IP:1080 https://ipinfo.io/ip
```

### Test Shadowsocks:
```bash
# Install client dulu
sudo apt install shadowsocks-libev
ss-local -s YOUR_SERVER_IP -p 8388 -l 1081 -k YOUR_PASSWORD -m aes-256-gcm
curl -x socks5://127.0.0.1:1081 https://ipinfo.io/ip
```

## Troubleshooting

Jika mengalami masalah, baca file `panduan-setup.md` untuk:
- Panduan troubleshooting lengkap
- Solusi masalah umum
- Command untuk debugging
- Tips optimasi performance

## Support

Untuk bantuan lebih lanjut:
1. Baca `panduan-setup.md`
2. Cek log di `/var/log/`
3. Gunakan command `systemctl status <service>`
4. Monitor dengan `journalctl -f`

---
**Dibuat untuk sistem Linux/Ubuntu dengan bahasa Indonesia** 🇮🇩