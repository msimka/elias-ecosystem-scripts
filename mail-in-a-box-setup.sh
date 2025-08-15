#!/bin/bash

# Mail-in-a-Box VPS Setup Script
# Implements the 30-day email relay architecture for Elias ecosystem
# Version: 1.0
# Author: Elias Ecosystem

set -e

echo "📧 Mail-in-a-Box Setup for Elias Ecosystem"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root"
    echo "   Please run: sudo $0"
    exit 1
fi

# Check if running on Ubuntu 22.04
if ! grep -q "Ubuntu 22.04" /etc/os-release 2>/dev/null; then
    echo "⚠️  Warning: Mail-in-a-Box requires Ubuntu 22.04 LTS"
    echo "   Current OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo ""
    read -p "Continue anyway? (y/N): " continue_anyway
    if [[ ! $continue_anyway =~ ^[Yy]$ ]]; then
        echo "❌ Exiting. Please use Ubuntu 22.04 LTS"
        exit 1
    fi
fi

# Check internet connectivity
echo "🌐 Checking internet connectivity..."
if ! ping -c 1 google.com &> /dev/null; then
    echo "❌ No internet connection. Please check network settings."
    exit 1
fi
echo "✅ Internet connectivity confirmed"

# Update system packages
echo ""
echo "📦 Updating system packages..."
apt update
apt upgrade -y

# Install required dependencies
echo ""
echo "🔧 Installing dependencies..."
apt install -y curl wget git

# Check if Mail-in-a-Box is already installed
if [ -d "/root/mailinabox" ]; then
    echo ""
    echo "⚠️  Mail-in-a-Box appears to be already installed"
    echo "   Directory /root/mailinabox exists"
    read -p "Continue with reinstallation? (y/N): " reinstall
    if [[ ! $reinstall =~ ^[Yy]$ ]]; then
        echo "❌ Exiting. Remove /root/mailinabox to do a fresh install."
        exit 1
    fi
fi

# Prompt for configuration details
echo ""
echo "📋 Mail-in-a-Box Configuration"
echo "=============================="
echo ""

# Hostname configuration
echo "Enter hostname for mail server (e.g., mail.elias.garden):"
read -p "Hostname: " hostname
if [ -z "$hostname" ]; then
    echo "❌ Hostname is required"
    exit 1
fi

# Admin email configuration
echo ""
echo "Enter admin email address:"
read -p "Admin email: " admin_email
if [ -z "$admin_email" ]; then
    echo "❌ Admin email is required"
    exit 1
fi

# Confirm configuration
echo ""
echo "📝 Configuration Summary:"
echo "  Hostname: $hostname"
echo "  Admin Email: $admin_email"
echo "  OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "  IP Address: $(curl -s https://api.ipify.org)"
echo ""
read -p "Proceed with installation? (y/N): " confirm_install

if [[ ! $confirm_install =~ ^[Yy]$ ]]; then
    echo "❌ Installation cancelled"
    exit 1
fi

# Set hostname
echo ""
echo "🏷️  Setting hostname..."
hostnamectl set-hostname "$hostname"
echo "127.0.1.1 $hostname" >> /etc/hosts

# Download and run Mail-in-a-Box installer
echo ""
echo "📥 Downloading Mail-in-a-Box installer..."
cd /root
curl -s https://mailinabox.email/setup.sh > setup.sh
chmod +x setup.sh

echo ""
echo "🚀 Starting Mail-in-a-Box installation..."
echo "   This will take 15-30 minutes depending on server performance"
echo "   The installer will prompt for additional configuration"
echo ""

# Set environment variables for automated installation
export PRIMARY_HOSTNAME="$hostname"
export ADMIN_EMAIL="$admin_email"

# Run the installer
./setup.sh

# Post-installation configuration
echo ""
echo "🎉 Mail-in-a-Box installation completed!"
echo ""
echo "📊 Post-Installation Status:"
echo "  Hostname: $hostname"
echo "  Admin Email: $admin_email"
echo "  Web Admin: https://$hostname/admin"
echo "  IP Address: $(curl -s https://api.ipify.org)"
echo ""

# Display DNS configuration instructions
echo "🔧 DNS Configuration Required:"
echo "================================"
echo ""
echo "Add these DNS records to your domain registrar:"
echo ""
echo "A Records:"
echo "  $hostname.     A     $(curl -s https://api.ipify.org)"
echo "  autoconfig.$hostname. A $(curl -s https://api.ipify.org)"
echo "  autodiscover.$hostname. A $(curl -s https://api.ipify.org)"
echo ""
echo "MX Record:"
echo "  @              MX 10 $hostname."
echo ""
echo "🔐 SSL Certificate:"
echo "  Certificates will be automatically generated after DNS propagation"
echo "  This may take up to 24 hours"
echo ""

# Display next steps
echo "📋 Next Steps:"
echo "=============="
echo "1. Configure DNS records as shown above"
echo "2. Wait for DNS propagation (up to 24 hours)"
echo "3. Access admin panel: https://$hostname/admin"
echo "4. Add custom domains for Elias ecosystem"
echo "5. Test email functionality"
echo ""

# Create configuration backup
echo "💾 Creating configuration backup..."
mkdir -p /root/elias-backups
tar -czf "/root/elias-backups/mailinabox-config-$(date +%Y%m%d_%H%M%S).tar.gz" /root/mailinabox/

echo ""
echo "✨ Mail-in-a-Box setup complete!"
echo "   Configuration backup saved to /root/elias-backups/"
echo ""
echo "📚 Documentation: https://docs.elias.dev/email-relay"
echo "🆘 Support: Contact Elias ecosystem team"