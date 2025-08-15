# Elias Ecosystem Installation Scripts

**Free for Consumers** - Essential installation utilities for the Elias constellation ecosystem.

## Quick Start

### Guix Channel Setup
Eliminates heredoc copy-paste errors for constellation node setup:

```bash
curl -fsSL https://raw.githubusercontent.com/msimka/elias-ecosystem-scripts/master/guix-elias-channel-setup.sh | bash
```

### Email Server Deployment
Deploy Mail-in-a-Box for 30-day relay architecture:

```bash
curl -fsSL https://raw.githubusercontent.com/msimka/elias-ecosystem-scripts/master/mail-in-a-box-setup.sh | sudo bash
```

### Telnyx API Testing
Test CoolGirls platform integration with Telnyx services:

```bash
curl -fsSL https://raw.githubusercontent.com/msimka/elias-ecosystem-scripts/master/telnyx-integration-test.py | python3
```

### Constellation Node Setup
Configure P2P file synchronization for constellation nodes:

```bash
curl -fsSL https://raw.githubusercontent.com/msimka/elias-ecosystem-scripts/master/syncthing-constellation-setup.sh | bash
```

### mu4e Email Integration
Set up org-mode email workflow with multi-platform support:

```bash
curl -fsSL https://raw.githubusercontent.com/msimka/elias-ecosystem-scripts/master/mu4e-elias-setup.sh | bash
```

### Available Scripts

- **`guix-elias-channel-setup.sh`** - Interactive Guix channel configuration
  - Handles both Elias + default channels and default-only fallback
  - Automatic error handling and recovery
  - Clear progress feedback

- **`mail-in-a-box-setup.sh`** - Email server deployment for 30-day relay architecture
  - Automated Mail-in-a-Box installation on Ubuntu 22.04
  - DNS configuration guidance
  - SSL certificate automation

- **`telnyx-integration-test.py`** - Telnyx API integration testing for CoolGirls platform
  - SMS, Voice, and eSIM capability testing
  - Account balance and connection verification
  - Comprehensive test suite with detailed reporting

- **`syncthing-constellation-setup.sh`** - Constellation P2P file synchronization setup
  - Automated Syncthing installation and configuration
  - Node-specific device naming and folder setup
  - Auto-discovery and connection management

- **`mu4e-elias-setup.sh`** - mu4e email integration with org-mode workflow
  - Automated mu4e and OfflineIMAP installation
  - Multi-account email configuration for all platforms
  - ApeRocks task integration and email analytics

## Features

✅ **Error-proof Installation** - No more heredoc EOF copy-paste failures  
✅ **Interactive Prompts** - Step-by-step guidance for all users  
✅ **Fallback Options** - Default channels if authentication issues  
✅ **Clear Feedback** - Progress indicators and error messages  

## Support

- **Documentation**: https://docs.elias.dev
- **Issues**: https://github.com/msimka/elias-ecosystem-scripts/issues
- **Community**: Part of the Elias constellation ecosystem

## Architecture

This repository implements the "Free for Consumers" aspect of the Elias business model, providing essential setup tools at no cost to encourage constellation adoption.

---

*Part of the Elias Ecosystem - AI-native infrastructure for the next generation of applications.*