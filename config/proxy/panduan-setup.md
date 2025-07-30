# Panduan Setup Server Proxy Lengkap

Panduan lengkap untuk menginstall dan mengkonfigurasi server proxy dengan SOCKS5 (Dante), Shadowsocks, WireGuard, dan DNS Cloudflare pada sistem Linux/Ubuntu.

## Daftar Isi

1. [Persyaratan Sistem](#persyaratan-sistem)
2. [Persiapan Server](#persiapan-server)
3. [Instalasi Otomatis](#instalasi-otomatis)
4. [Instalasi Manual](#instalasi-manual)
5. [Konfigurasi Lanjutan](#konfigurasi-lanjutan)
6. [Testing dan Verifikasi](#testing-dan-verifikasi)
7. [Troubleshooting](#troubleshooting)
8. [Keamanan](#keamanan)
9. [Monitoring](#monitoring)
10. [FAQ](#faq)

## Persyaratan Sistem

### Sistem Operasi yang Didukung
- Ubuntu 18.04 LTS atau lebih baru
- Debian 10 atau lebih baru
- CentOS 7/8 (dengan penyesuaian)
- Rocky Linux / AlmaLinux

### Spesifikasi Minimum
- **RAM**: 1GB (2GB direkomendasikan)
- **Storage**: 10GB ruang kosong
- **Network**: Koneksi internet stabil
- **Root Access**: Diperlukan untuk instalasi

### Port yang Digunakan
- **1080/tcp**: SOCKS5 Dante Proxy
- **8388/tcp**: Shadowsocks
- **51820/udp**: WireGuard VPN
- **53/tcp,udp**: DNS (opsional)
- **22/tcp**: SSH (untuk manajemen)

## Persiapan Server

### 1. Update Sistem
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git unzip
```

### 2. Konfigurasi Firewall Dasar
```bash
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 1080/tcp    # SOCKS5
sudo ufw allow 8388/tcp    # Shadowsocks  
sudo ufw allow 51820/udp   # WireGuard
```

### 3. Optimasi Sistem
```bash
# Tingkatkan file descriptor limit
echo "* soft nofile 65535" >> /etc/security/limits.conf
echo "* hard nofile 65535" >> /etc/security/limits.conf

# Optimasi kernel untuk networking
echo "net.core.rmem_max = 67108864" >> /etc/sysctl.conf
echo "net.core.wmem_max = 67108864" >> /etc/sysctl.conf
echo "net.ipv4.tcp_rmem = 4096 65536 67108864" >> /etc/sysctl.conf
echo "net.ipv4.tcp_wmem = 4096 65536 67108864" >> /etc/sysctl.conf
sysctl -p
```

## Instalasi Otomatis

### Menggunakan Script Setup
```bash
# Download file konfigurasi
git clone https://github.com/helena1994/mcp-server-modular.git
cd mcp-server-modular/config/proxy

# Jalankan script setup
sudo chmod +x setup-proxy-server.sh
sudo ./setup-proxy-server.sh
```

### Menu Instalasi
Script akan menampilkan menu:
1. **Install semua** - SOCKS5 + Shadowsocks + WireGuard + DNS
2. **Install Dante SOCKS5 saja**
3. **Install Shadowsocks saja**
4. **Install WireGuard saja**
5. **Konfigurasi DNS saja**
6. **Status layanan**
7. **Informasi koneksi**

## Instalasi Manual

### 1. Install Dante SOCKS5 Proxy

```bash
# Install paket
sudo apt install -y dante-server

# Copy konfigurasi
sudo cp danted.conf /etc/danted.conf

# Buat user proxy
sudo useradd -r -s /bin/false proxy

# Enable dan start service
sudo systemctl enable danted
sudo systemctl start danted
```

### 2. Install Shadowsocks

```bash
# Install shadowsocks-libev
sudo apt install -y shadowsocks-libev

# Copy konfigurasi
sudo cp shadowsocks-config.json /etc/shadowsocks-libev/config.json

# PENTING: Ganti password dalam file konfigurasi
sudo nano /etc/shadowsocks-libev/config.json

# Enable dan start service
sudo systemctl enable shadowsocks-libev
sudo systemctl start shadowsocks-libev
```

### 3. Install WireGuard

```bash
# Install WireGuard
sudo apt install -y wireguard wireguard-tools

# Generate kunci server
wg genkey | sudo tee /etc/wireguard/server_private.key | wg pubkey | sudo tee /etc/wireguard/server_public.key

# Copy dan edit konfigurasi
sudo cp wg0.conf /etc/wireguard/wg0.conf
sudo chmod 600 /etc/wireguard/wg0.conf

# Edit konfigurasi dengan kunci yang benar
sudo nano /etc/wireguard/wg0.conf

# Enable IP forwarding
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Enable dan start service
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

### 4. Konfigurasi DNS

```bash
# Backup konfigurasi asli
sudo cp /etc/resolv.conf /etc/resolv.conf.backup

# Copy konfigurasi DNS
sudo cp resolv.conf /etc/resolv.conf

# Proteksi file dari perubahan otomatis
sudo chattr +i /etc/resolv.conf
```

## Konfigurasi Lanjutan

### Konfigurasi Dante SOCKS5

#### Menambah Autentikasi Username
```bash
# Edit file konfigurasi
sudo nano /etc/danted.conf

# Ganti baris method
method: username

# Buat user untuk SOCKS5
sudo useradd -r -s /bin/false socks_user
sudo passwd socks_user
```

#### Membatasi Akses IP
```bash
# Edit /etc/danted.conf
client pass {
    from: 192.168.1.0/24 to: 0.0.0.0/0
    log: error connect disconnect
}
```

### Konfigurasi Shadowsocks

#### Ganti Password dan Port
```bash
sudo nano /etc/shadowsocks-libev/config.json

# Contoh konfigurasi aman:
{
    "server": "0.0.0.0",
    "server_port": 8443,  # Port custom
    "password": "Password_Sangat_Kuat_123!@#",
    "timeout": 300,
    "method": "aes-256-gcm"
}
```

#### Enable Shadowsocks dengan systemd
```bash
# Buat file service
sudo tee /etc/systemd/system/shadowsocks-server.service > /dev/null <<EOF
[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
Type=simple
User=nobody
ExecStart=/usr/bin/ss-server -c /etc/shadowsocks-libev/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable shadowsocks-server
sudo systemctl start shadowsocks-server
```

### Konfigurasi WireGuard

#### Menambah Klien Baru
```bash
# Generate kunci klien
wg genkey | tee client_private.key | wg pubkey > client_public.key

# Tambahkan ke konfigurasi server
sudo nano /etc/wireguard/wg0.conf

# Tambahkan blok [Peer]
[Peer]
PublicKey = ISI_DENGAN_PUBLIC_KEY_CLIENT
AllowedIPs = 10.8.0.2/32

# Restart WireGuard
sudo systemctl restart wg-quick@wg0
```

#### Konfigurasi Klien
Buat file konfigurasi untuk klien:
```ini
[Interface]
PrivateKey = PRIVATE_KEY_CLIENT
Address = 10.8.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = PUBLIC_KEY_SERVER
Endpoint = IP_SERVER_ANDA:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

## Testing dan Verifikasi

### Test SOCKS5 Proxy
```bash
# Test dengan curl
curl -x socks5://IP_SERVER:1080 https://ipinfo.io/ip

# Test dengan browser (Firefox)
# Proxy: IP_SERVER
# Port: 1080
# Type: SOCKS v5
```

### Test Shadowsocks
```bash
# Install shadowsocks client
sudo apt install -y shadowsocks-libev

# Test koneksi
ss-local -s IP_SERVER -p 8388 -l 1081 -k PASSWORD -m aes-256-gcm -f /tmp/ss-local.pid

# Test dengan curl
curl -x socks5://127.0.0.1:1081 https://ipinfo.io/ip
```

### Test WireGuard
```bash
# Cek status server
sudo wg show

# Test dari klien
ping 10.8.0.1

# Test koneksi internet melalui VPN
curl https://ipinfo.io/ip
```

### Test DNS
```bash
# Test resolusi DNS
nslookup google.com
dig google.com @1.1.1.1

# Test kecepatan DNS
time nslookup google.com
```

## Troubleshooting

### Masalah Umum

#### 1. Service Tidak Bisa Start
```bash
# Cek status service
sudo systemctl status danted
sudo systemctl status shadowsocks-libev
sudo systemctl status wg-quick@wg0

# Cek log error
sudo journalctl -u danted -f
sudo journalctl -u shadowsocks-libev -f
sudo journalctl -u wg-quick@wg0 -f
```

#### 2. Port Sudah Digunakan
```bash
# Cek port yang sedang digunakan
sudo netstat -tulpn | grep :1080
sudo netstat -tulpn | grep :8388
sudo netstat -tulpn | grep :51820

# Matikan service yang menggunakan port
sudo fuser -k 1080/tcp
```

#### 3. Koneksi Ditolak
```bash
# Cek firewall
sudo ufw status
sudo iptables -L

# Buka port yang diperlukan
sudo ufw allow 1080/tcp
sudo ufw allow 8388/tcp
sudo ufw allow 51820/udp
```

#### 4. DNS Tidak Bekerja
```bash
# Cek konfigurasi DNS
cat /etc/resolv.conf

# Test DNS server
nslookup google.com 1.1.1.1

# Restart network service
sudo systemctl restart systemd-resolved
```

### Log File Lokasi
- **Dante**: `/var/log/danted.log`
- **Shadowsocks**: `journalctl -u shadowsocks-libev`
- **WireGuard**: `journalctl -u wg-quick@wg0`
- **System**: `/var/log/syslog`

### Debugging Commands
```bash
# Monitor koneksi real-time
sudo ss -tulpn | grep -E "(1080|8388|51820)"

# Monitor lalu lintas jaringan
sudo tcpdump -i any port 1080
sudo tcpdump -i any port 8388
sudo tcpdump -i wg0

# Cek konfigurasi jaringan
ip addr show
ip route show
```

## Keamanan

### Hardening Server

#### 1. Konfigurasi SSH yang Aman
```bash
sudo nano /etc/ssh/sshd_config

# Tambahkan konfigurasi:
Port 2222                    # Port non-standard
PermitRootLogin no          # Disable root login
PasswordAuthentication no   # Gunakan key-based auth
AllowUsers your_username    # Batasi user yang bisa login

sudo systemctl restart ssh
```

#### 2. Install Fail2Ban
```bash
sudo apt install -y fail2ban

# Konfigurasi untuk SSH
sudo tee /etc/fail2ban/jail.local > /dev/null <<EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = 2222
logpath = /var/log/auth.log
EOF

sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

#### 3. Monitoring dengan Logwatch
```bash
sudo apt install -y logwatch

# Konfigurasi laporan harian
sudo nano /etc/cron.daily/00logwatch

#!/bin/bash
/usr/sbin/logwatch --output mail --mailto your@email.com --detail high
```

### Password dan Kunci yang Kuat

#### Generate Password Kuat
```bash
# Password acak 32 karakter
openssl rand -base64 32

# Password dengan karakter khusus
tr -dc 'A-Za-z0-9!@#$%^&*()_+' < /dev/urandom | head -c 32
```

#### Generate WireGuard Keys
```bash
# Generate kunci dengan aman
umask 077
wg genkey | tee private.key | wg pubkey > public.key
```

## Monitoring

### Script Monitoring Otomatis
```bash
#!/bin/bash
# File: monitor-proxy.sh

# Cek status service
echo "=== Status Layanan ==="
systemctl is-active danted && echo "Dante: AKTIF" || echo "Dante: MATI"
systemctl is-active shadowsocks-libev && echo "Shadowsocks: AKTIF" || echo "Shadowsocks: MATI"
systemctl is-active wg-quick@wg0 && echo "WireGuard: AKTIF" || echo "WireGuard: MATI"

# Cek koneksi port
echo -e "\n=== Status Port ==="
nc -z localhost 1080 && echo "Port 1080: TERBUKA" || echo "Port 1080: TERTUTUP"
nc -z localhost 8388 && echo "Port 8388: TERBUKA" || echo "Port 8388: TERTUTUP"

# Cek penggunaan bandwidth
echo -e "\n=== Penggunaan Bandwidth ==="
vnstat -i eth0 | grep "today"

# Cek load sistem
echo -e "\n=== Load Sistem ==="
uptime
free -h
df -h | grep -v tmpfs
```

### Setup Monitoring dengan Crontab
```bash
# Edit crontab
crontab -e

# Tambahkan monitoring setiap 5 menit
*/5 * * * * /path/to/monitor-proxy.sh >> /var/log/proxy-monitor.log

# Restart service jika mati
*/10 * * * * systemctl is-active danted || systemctl restart danted
*/10 * * * * systemctl is-active shadowsocks-libev || systemctl restart shadowsocks-libev
```

## FAQ

### Q: Bagaimana cara mengganti port default?
**A:** Edit file konfigurasi masing-masing service:
- Dante: Edit `internal: 0.0.0.0 port = XXXX` di `/etc/danted.conf`
- Shadowsocks: Edit `"server_port": XXXX` di `/etc/shadowsocks-libev/config.json`
- WireGuard: Edit `ListenPort = XXXX` di `/etc/wireguard/wg0.conf`

### Q: Apakah bisa menggunakan domain name instead of IP?
**A:** Ya, untuk konfigurasi klien bisa menggunakan domain name di bagian server/endpoint.

### Q: Bagaimana cara backup konfigurasi?
**A:** 
```bash
tar -czf proxy-backup-$(date +%Y%m%d).tar.gz \
  /etc/danted.conf \
  /etc/shadowsocks-libev/ \
  /etc/wireguard/ \
  /etc/resolv.conf
```

### Q: Bisakah semua service berjalan bersamaan?
**A:** Ya, semua service menggunakan port yang berbeda dan bisa berjalan bersamaan.

### Q: Bagaimana cara menambah user untuk SOCKS5?
**A:** Jika menggunakan autentikasi username, tambah user sistem:
```bash
sudo useradd -r -s /bin/false username
sudo passwd username
```

### Q: Apakah perlu SSL certificate?
**A:** Untuk setup dasar tidak perlu, tapi untuk keamanan extra bisa menggunakan:
- Shadowsocks dengan v2ray-plugin (TLS)
- SOCKS5 dengan stunnel (SSL wrapper)

### Q: Bagaimana cara update/upgrade?
**A:**
```bash
# Update sistem dan paket
sudo apt update && sudo apt upgrade -y

# Restart services setelah update
sudo systemctl restart danted shadowsocks-libev wg-quick@wg0
```

### Q: Troubleshooting koneksi lambat?
**A:**
1. Cek bandwidth server: `speedtest-cli`
2. Monitor CPU usage: `htop`
3. Cek konfigurasi kernel networking
4. Periksa MTU size untuk WireGuard
5. Gunakan `iperf3` untuk test performance

---

## Kontak dan Support

Jika mengalami masalah atau butuh bantuan:
1. Cek log file di `/var/log/`
2. Gunakan command troubleshooting di atas
3. Periksa konfigurasi firewall dan network
4. Pastikan semua dependency terinstall dengan benar

**Selamat menggunakan server proxy!** 🚀