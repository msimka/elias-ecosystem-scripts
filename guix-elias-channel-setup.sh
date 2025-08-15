#!/bin/bash

# Elias Guix Channel Setup Script
# Eliminates heredoc copy-paste errors for constellation node setup
# Version: 1.0
# Author: Elias Ecosystem

set -e

echo "🚀 Elias Guix Channel Setup"
echo "=========================="
echo ""

# Check if running on Guix System
if ! command -v guix &> /dev/null; then
    echo "❌ Error: Guix not found. Please install Guix first."
    echo "   Visit: https://guix.gnu.org/manual/en/html_node/Installation.html"
    exit 1
fi

# Create config directory if it doesn't exist
mkdir -p ~/.config/guix

echo "📋 Setting up Elias channel configuration..."

# Check if channels.scm already exists
if [ -f ~/.config/guix/channels.scm ]; then
    echo "⚠️  Existing channels.scm found. Creating backup..."
    cp ~/.config/guix/channels.scm ~/.config/guix/channels.scm.backup.$(date +%Y%m%d_%H%M%S)
    echo "   Backup saved as: ~/.config/guix/channels.scm.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Prompt user for channel preference
echo ""
echo "Choose your channel configuration:"
echo "1) Elias channel + default channels (recommended for constellation nodes)"
echo "2) Default channels only (fallback if authentication issues)"
echo ""
read -p "Enter choice (1 or 2): " choice

case $choice in
    1)
        echo "🔧 Creating Elias + default channels configuration..."
        cat > ~/.config/guix/channels.scm << 'EOF'
(cons* (channel
         (name 'elias)
         (url "https://gitlab.com/elias-ecosystem/channels.git"))
       %default-channels)
EOF
        echo "✅ Elias channel configuration created"
        ;;
    2)
        echo "🔧 Creating default channels only configuration..."
        cat > ~/.config/guix/channels.scm << 'EOF'
%default-channels
EOF
        echo "✅ Default channels configuration created"
        ;;
    *)
        echo "❌ Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "📥 Running guix pull to update channels..."
echo "   This may take several minutes..."
echo ""

# Run guix pull with error handling
if guix pull; then
    echo ""
    echo "🎉 Guix channel setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "• Your Guix channels are now configured"
    echo "• You can install Elias-specific packages (if using option 1)"
    echo "• Continue with constellation node setup"
    echo ""
    echo "📊 Channel status:"
    guix describe
else
    echo ""
    echo "❌ Error during guix pull"
    echo ""
    echo "Common solutions:"
    echo "1. Check internet connection"
    echo "2. If using Elias channel, ensure you have access to the GitLab repository"
    echo "3. Try option 2 (default channels only) as a fallback"
    echo ""
    echo "🔧 To reset and try again:"
    echo "   rm ~/.config/guix/channels.scm"
    echo "   curl -fsSL https://install.elias.dev/guix | sh"
    echo ""
    echo "🆘 For support, share this error with the Elias team"
    exit 1
fi

echo ""
echo "📚 Documentation: https://docs.elias.dev/constellation/guix-setup"
echo "🎯 Next: Continue with constellation node configuration"