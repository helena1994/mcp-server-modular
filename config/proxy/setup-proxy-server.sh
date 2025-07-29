#!/bin/bash

# Script Setup Server Proxy Lengkap
# Menginstall dan mengkonfigurasi SOCKS5 (Dante), Shadowsocks, WireGuard, dan DNS
# Untuk sistem Linux/Ubuntu
# Author: Sistem Proxy Modular
# Versi: 1.0

set -e

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fungsi untuk logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUKSES]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[PERINGATAN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Fungsi untuk memeriksa apakah script dijalankan sebagai root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Script ini harus dijalankan sebagai root (gunakan sudo)"
        exit 1
    fi
}

# Fungsi untuk update sistem
update_system() {
    log_info "Memperbarui sistem..."
    apt update && apt upgrade -y
    apt install -y curl wget software-properties-common apt-transport-https ca-certificates gnupg lsb-release
}

# Fungsi untuk install Dante SOCKS5 proxy
install_dante() {
    log_info "Menginstall Dante SOCKS5 proxy..."
    apt install -y dante-server
    
    # Backup konfigurasi asli
    if [ -f /etc/danted.conf ]; then
        cp /etc/danted.conf /etc/danted.conf.backup
    fi
    
    # Copy konfigurasi Dante dari repo
    if [ -f "./danted.conf" ]; then
        cp ./danted.conf /etc/danted.conf
    else
        log_warning "File danted.conf tidak ditemukan, menggunakan konfigurasi default"
        cat > /etc/danted.conf << 'EOF'
# Konfigurasi Dante SOCKS5 - Setup Default
logoutput: /var/log/danted.log
internal: 0.0.0.0 port = 1080
external: eth0
method: username none
user.privileged: proxy
user.notprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error connect disconnect
}

pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
    command: bind connect udpassociate
    log: error connect disconnect
}
EOF
    fi
    
    # Enable dan start service
    systemctl enable danted
    systemctl restart danted
    log_success "Dante SOCKS5 proxy berhasil diinstall dan dikonfigurasi"
}

# Fungsi untuk install Shadowsocks
install_shadowsocks() {
    log_info "Menginstall Shadowsocks..."
    apt install -y shadowsocks-libev
    
    # Backup konfigurasi asli
    if [ -f /etc/shadowsocks-libev/config.json ]; then
        cp /etc/shadowsocks-libev/config.json /etc/shadowsocks-libev/config.json.backup
    fi
    
    # Copy konfigurasi Shadowsocks dari repo
    if [ -f "./shadowsocks-config.json" ]; then
        cp ./shadowsocks-config.json /etc/shadowsocks-libev/config.json
    else
        log_warning "File shadowsocks-config.json tidak ditemukan, menggunakan konfigurasi default"
        # Generate password acak
        SS_PASSWORD=$(openssl rand -base64 32)
        cat > /etc/shadowsocks-libev/config.json << EOF
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "password": "$SS_PASSWORD",
    "timeout": 300,
    "method": "aes-256-gcm",
    "fast_open": false,
    "workers": 1
}
EOF
        log_info "Password Shadowsocks yang dihasilkan: $SS_PASSWORD"
    fi
    
    # Enable dan start service
    systemctl enable shadowsocks-libev
    systemctl restart shadowsocks-libev
    log_success "Shadowsocks berhasil diinstall dan dikonfigurasi"
}

# Fungsi untuk install WireGuard
install_wireguard() {
    log_info "Menginstall WireGuard..."
    apt install -y wireguard wireguard-tools
    
    # Copy konfigurasi WireGuard dari repo
    if [ -f "./wg0.conf" ]; then
        cp ./wg0.conf /etc/wireguard/wg0.conf
        chmod 600 /etc/wireguard/wg0.conf
    else
        log_warning "File wg0.conf tidak ditemukan, silakan konfigurasikan manual"
        log_info "Contoh konfigurasi ada di /etc/wireguard/"
    fi
    
    # Enable IP forwarding
    echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
    echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.conf
    sysctl -p
    
    log_success "WireGuard berhasil diinstall"
}

# Fungsi untuk konfigurasi DNS
configure_dns() {
    log_info "Mengkonfigurasi DNS..."
    
    # Backup konfigurasi DNS asli
    if [ -f /etc/resolv.conf ]; then
        cp /etc/resolv.conf /etc/resolv.conf.backup
    fi
    
    # Copy konfigurasi DNS dari repo atau buat default
    if [ -f "./resolv.conf" ]; then
        cp ./resolv.conf /etc/resolv.conf
    else
        log_warning "File resolv.conf tidak ditemukan, menggunakan Cloudflare DNS"
        cat > /etc/resolv.conf << 'EOF'
# DNS Cloudflare - Konfigurasi Cepat dan Aman
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 2606:4700:4700::1111
nameserver 2606:4700:4700::1001

# Opsi DNS
options timeout:2
options attempts:3
options rotate
options single-request-reopen
EOF
    fi
    
    # Pastikan file tidak bisa diubah secara otomatis
    chattr +i /etc/resolv.conf
    log_success "DNS berhasil dikonfigurasi dengan Cloudflare"
}

# Fungsi untuk konfigurasi firewall
configure_firewall() {
    log_info "Mengkonfigurasi firewall..."
    
    # Install ufw jika belum ada
    apt install -y ufw
    
    # Reset firewall
    ufw --force reset
    
    # Aturan dasar
    ufw default deny incoming
    ufw default allow outgoing
    
    # Izinkan SSH (port 22)
    ufw allow ssh
    
    # Izinkan port untuk proxy services
    ufw allow 1080/tcp   # SOCKS5 Dante
    ufw allow 8388/tcp   # Shadowsocks
    ufw allow 51820/udp  # WireGuard
    
    # Izinkan port DNS
    ufw allow 53/tcp
    ufw allow 53/udp
    
    # Enable firewall
    ufw --force enable
    
    log_success "Firewall berhasil dikonfigurasi"
}

# Fungsi untuk status layanan
show_service_status() {
    log_info "Status layanan proxy:"
    echo "================================="
    
    # Status Dante
    echo -n "Dante SOCKS5: "
    if systemctl is-active --quiet danted; then
        echo -e "${GREEN}AKTIF${NC}"
    else
        echo -e "${RED}TIDAK AKTIF${NC}"
    fi
    
    # Status Shadowsocks
    echo -n "Shadowsocks: "
    if systemctl is-active --quiet shadowsocks-libev; then
        echo -e "${GREEN}AKTIF${NC}"
    else
        echo -e "${RED}TIDAK AKTIF${NC}"
    fi
    
    # Status WireGuard
    echo -n "WireGuard: "
    if systemctl is-active --quiet wg-quick@wg0; then
        echo -e "${GREEN}AKTIF${NC}"
    else
        echo -e "${YELLOW}TIDAK AKTIF${NC} (perlu konfigurasi manual)"
    fi
    
    echo "================================="
}

# Fungsi untuk menampilkan informasi koneksi
show_connection_info() {
    log_info "Informasi koneksi proxy:"
    echo "================================="
    
    # IP Server
    SERVER_IP=$(curl -s ipinfo.io/ip || echo "Tidak dapat mendeteksi IP")
    echo "IP Server: $SERVER_IP"
    
    echo ""
    echo "SOCKS5 Proxy (Dante):"
    echo "  Host: $SERVER_IP"
    echo "  Port: 1080"
    echo "  Type: SOCKS5"
    echo ""
    
    echo "Shadowsocks:"
    echo "  Server: $SERVER_IP"
    echo "  Port: 8388"
    echo "  Method: aes-256-gcm"
    if [ -f /etc/shadowsocks-libev/config.json ]; then
        SS_PASS=$(grep '"password"' /etc/shadowsocks-libev/config.json | cut -d'"' -f4)
        echo "  Password: $SS_PASS"
    fi
    echo ""
    
    echo "WireGuard:"
    echo "  Interface: wg0"
    echo "  Port: 51820"
    echo "  Konfigurasi: /etc/wireguard/wg0.conf"
    
    echo "================================="
}

# Fungsi utama
main() {
    log_info "Memulai setup server proxy lengkap..."
    
    check_root
    
    # Menu pilihan
    echo "Pilih komponen yang ingin diinstall:"
    echo "1) Install semua (Dante + Shadowsocks + WireGuard + DNS)"
    echo "2) Install Dante SOCKS5 saja"
    echo "3) Install Shadowsocks saja"
    echo "4) Install WireGuard saja"
    echo "5) Konfigurasi DNS saja"
    echo "6) Status layanan"
    echo "7) Informasi koneksi"
    echo "0) Keluar"
    
    read -p "Masukkan pilihan (0-7): " choice
    
    case $choice in
        1)
            update_system
            install_dante
            install_shadowsocks
            install_wireguard
            configure_dns
            configure_firewall
            show_service_status
            show_connection_info
            log_success "Setup lengkap selesai!"
            ;;
        2)
            update_system
            install_dante
            configure_firewall
            show_service_status
            ;;
        3)
            update_system
            install_shadowsocks
            configure_firewall
            show_service_status
            ;;
        4)
            update_system
            install_wireguard
            configure_firewall
            show_service_status
            ;;
        5)
            configure_dns
            ;;
        6)
            show_service_status
            ;;
        7)
            show_connection_info
            ;;
        0)
            log_info "Keluar dari script"
            exit 0
            ;;
        *)
            log_error "Pilihan tidak valid"
            exit 1
            ;;
    esac
}

# Jalankan fungsi utama
main "$@"