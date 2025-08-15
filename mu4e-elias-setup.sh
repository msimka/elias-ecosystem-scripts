#!/bin/bash

# mu4e Email Integration Setup for Elias Ecosystem
# Configures mu4e with org-mode for seamless email workflow
# Version: 1.0
# Author: Elias Ecosystem

set -e

echo "📧 mu4e Email Integration Setup for Elias Ecosystem"
echo "==================================================="
echo ""

# Check if running on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
    CERT_FILE="/etc/ssl/cert.pem"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
    CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
else
    echo "❌ Unsupported platform: $OSTYPE"
    exit 1
fi

echo "🖥️  Platform detected: $PLATFORM"

# Check if Emacs is installed
if ! command -v emacs &> /dev/null; then
    echo "❌ Emacs not found. Please install Emacs first."
    echo "   macOS: brew install emacs"
    echo "   Linux: sudo apt install emacs"
    exit 1
fi

echo "✅ Emacs found: $(emacs --version | head -n1)"

# Install mu/mu4e
echo ""
echo "📦 Installing mu/mu4e..."

if [[ "$PLATFORM" == "macos" ]]; then
    if command -v brew &> /dev/null; then
        brew install mu
    else
        echo "❌ Homebrew not found. Please install Homebrew first."
        exit 1
    fi
elif [[ "$PLATFORM" == "linux" ]]; then
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y maildir-utils mu4e
    elif command -v yum &> /dev/null; then
        sudo yum install -y maildir-utils mu4e
    else
        echo "❌ Package manager not supported. Please install mu manually."
        exit 1
    fi
fi

echo "✅ mu/mu4e installed"

# Verify mu installation
if ! command -v mu &> /dev/null; then
    echo "❌ mu installation failed"
    exit 1
fi

echo "📧 mu version: $(mu --version)"

# Install mail sync tool
echo ""
echo "📥 Installing mail synchronization tool..."

if [[ "$PLATFORM" == "macos" ]]; then
    brew install offlineimap
    SYNC_TOOL="offlineimap"
elif [[ "$PLATFORM" == "linux" ]]; then
    if command -v apt &> /dev/null; then
        sudo apt install -y offlineimap
    elif command -v yum &> /dev/null; then
        sudo yum install -y offlineimap
    fi
    SYNC_TOOL="offlineimap"
fi

echo "✅ $SYNC_TOOL installed"

# Create directory structure
echo ""
echo "📁 Creating email directory structure..."

mkdir -p ~/Maildir/{elias-main,vocatar,coolgirls}/{INBOX,Sent,Drafts,Trash,Spam}/{cur,new,tmp}
mkdir -p ~/.config/mu4e
mkdir -p ~/constellation/shared/configs/email

echo "✅ Directory structure created"

# Prompt for email configuration
echo ""
echo "🔧 Email Configuration"
echo "====================="

# Get Mail-in-a-Box server details
read -p "Mail-in-a-Box server (default: mail.elias.garden): " MAIL_SERVER
MAIL_SERVER=${MAIL_SERVER:-mail.elias.garden}

echo ""
echo "Enter passwords for your email accounts:"
echo "(These will be stored securely in your system keychain)"

# Configure passwords in keychain (macOS) or prompt for alternative storage
if [[ "$PLATFORM" == "macos" ]]; then
    echo ""
    echo "🔐 Configuring macOS Keychain..."
    
    for account in "mike@elias.garden" "mike@vocatar.com" "mike@coolgirls.com"; do
        echo "Setting up password for $account..."
        read -s -p "Password for $account: " password
        echo ""
        
        # Add to macOS Keychain
        security add-internet-password \
            -s "$MAIL_SERVER" \
            -a "$account" \
            -w "$password" \
            -U 2>/dev/null || \
        security update-internet-password \
            -s "$MAIL_SERVER" \
            -a "$account" \
            -w "$password"
    done
    
    echo "✅ Passwords stored in macOS Keychain"
    
    # Create password retrieval script
    cat > ~/.offlineimap.py << 'EOF'
#!/usr/bin/env python3
import subprocess

def get_password(server, username):
    """Get password from macOS Keychain"""
    try:
        result = subprocess.run([
            'security', 'find-internet-password',
            '-s', server,
            '-a', username,
            '-w'
        ], capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        import getpass
        return getpass.getpass(f"Password for {username}@{server}: ")
EOF
    
    chmod +x ~/.offlineimap.py
    
else
    echo "⚠️  Linux password storage setup required manually"
    echo "   Please set up pass or gnome-keyring for secure password storage"
fi

# Create OfflineIMAP configuration
echo ""
echo "📧 Creating OfflineIMAP configuration..."

cat > ~/.offlineimaprc << EOF
[general]
accounts = elias-main, vocatar, coolgirls
maxsyncaccounts = 3
pythonfile = ~/.offlineimap.py

[Account elias-main]
localrepository = elias-main-local
remoterepository = elias-main-remote
autorefresh = 0.5
quick = 10

[Repository elias-main-local]
type = Maildir
localfolders = ~/Maildir/elias-main

[Repository elias-main-remote]
type = IMAP
remotehost = $MAIL_SERVER
remoteuser = mike@elias.garden
remotepasseval = get_password("$MAIL_SERVER", "mike@elias.garden")
ssl = yes
sslcacertfile = $CERT_FILE
maxconnections = 2
folderfilter = lambda foldername: foldername in ['INBOX', 'Sent', 'Drafts', 'Trash', 'Spam']

[Account vocatar]
localrepository = vocatar-local
remoterepository = vocatar-remote
autorefresh = 0.5
quick = 10

[Repository vocatar-local]
type = Maildir
localfolders = ~/Maildir/vocatar

[Repository vocatar-remote]
type = IMAP
remotehost = $MAIL_SERVER
remoteuser = mike@vocatar.com
remotepasseval = get_password("$MAIL_SERVER", "mike@vocatar.com")
ssl = yes
sslcacertfile = $CERT_FILE
maxconnections = 2
folderfilter = lambda foldername: foldername in ['INBOX', 'Sent', 'Drafts', 'Trash', 'Spam']

[Account coolgirls]
localrepository = coolgirls-local
remoterepository = coolgirls-remote
autorefresh = 0.5
quick = 10

[Repository coolgirls-local]
type = Maildir
localfolders = ~/Maildir/coolgirls

[Repository coolgirls-remote]
type = IMAP
remotehost = $MAIL_SERVER
remoteuser = mike@coolgirls.com
remotepasseval = get_password("$MAIL_SERVER", "mike@coolgirls.com")
ssl = yes
sslcacertfile = $CERT_FILE
maxconnections = 2
folderfilter = lambda foldername: foldername in ['INBOX', 'Sent', 'Drafts', 'Trash', 'Spam']
EOF

echo "✅ OfflineIMAP configuration created"

# Create mu4e Emacs configuration
echo ""
echo "🎯 Creating mu4e Emacs configuration..."

cat > ~/constellation/shared/configs/email/mu4e-elias-config.el << EOF
;;; mu4e-elias-config.el --- mu4e configuration for Elias Ecosystem

;; Load mu4e
(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/mu/mu4e")
(require 'mu4e)

;; Basic mu4e settings
(setq mu4e-maildir "~/Maildir")
(setq mu4e-get-mail-command "$SYNC_TOOL")
(setq mu4e-update-interval 300) ; Update every 5 minutes
(setq mu4e-sent-messages-behavior 'delete)

;; SMTP configuration for Mail-in-a-Box
(setq message-send-mail-function 'smtpmail-send-it)
(setq smtpmail-smtp-server "$MAIL_SERVER")
(setq smtpmail-smtp-service 587)
(setq smtpmail-auth-credentials "~/.authinfo.gpg")

;; mu4e contexts for multiple email addresses
(setq mu4e-contexts
      \`(,(make-mu4e-context
          :name "elias-main"
          :match-func (lambda (msg)
                        (when msg
                          (string-prefix-p "/elias-main" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "mike@elias.garden")
                  (user-full-name . "Mike Simka")
                  (mu4e-drafts-folder . "/elias-main/Drafts")
                  (mu4e-sent-folder . "/elias-main/Sent")
                  (mu4e-trash-folder . "/elias-main/Trash")
                  (smtpmail-smtp-user . "mike@elias.garden")))
        
        ,(make-mu4e-context
          :name "vocatar"
          :match-func (lambda (msg)
                        (when msg
                          (string-prefix-p "/vocatar" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "mike@vocatar.com")
                  (user-full-name . "Mike Simka")
                  (mu4e-drafts-folder . "/vocatar/Drafts")
                  (mu4e-sent-folder . "/vocatar/Sent")
                  (mu4e-trash-folder . "/vocatar/Trash")
                  (smtpmail-smtp-user . "mike@vocatar.com")))
        
        ,(make-mu4e-context
          :name "coolgirls"
          :match-func (lambda (msg)
                        (when msg
                          (string-prefix-p "/coolgirls" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "mike@coolgirls.com")
                  (user-full-name . "Mike Simka")
                  (mu4e-drafts-folder . "/coolgirls/Drafts")
                  (mu4e-sent-folder . "/coolgirls/Sent")
                  (mu4e-trash-folder . "/coolgirls/Trash")
                  (smtpmail-smtp-user . "mike@coolgirls.com")))))

;; org-mode integration
(require 'org-mu4e)
(setq org-mu4e-link-query-in-headers-mode nil)

;; ApeRocks task integration
(defun ape-rocks-email-to-task ()
  "Convert current email to ApeRocks task"
  (interactive)
  (let* ((msg (mu4e-message-at-point))
         (subject (mu4e-message-field msg :subject))
         (from (mu4e-message-field msg :from))
         (date (mu4e-message-field msg :date))
         (msgid (mu4e-message-field msg :message-id)))
    (org-capture nil "e")))

;; Org capture template for emails
(setq org-capture-templates
      (append org-capture-templates
              '(("e" "Email Task" entry
                 (file+headline "~/constellation/shared/todos/email-tasks.org" "Email Tasks")
                 "* TODO %:subject\\n  :PROPERTIES:\\n  :EMAIL_FROM: %:from\\n  :EMAIL_DATE: %:date\\n  :EMAIL_MSGID: %:message-id\\n  :END:\\n  \\n  %a\\n  \\n  %?"))))

;; Platform-specific signatures
(setq mu4e-compose-signature-function
      (lambda ()
        (cond
         ((string-match "vocatar" (message-sendmail-envelope-from))
          "Best regards,\\nMike Simka\\nVocatar Voice Platform\\nhttps://vocatar.com")
         ((string-match "coolgirls" (message-sendmail-envelope-from))
          "Best regards,\\nMike Simka\\nCoolGirls Phone Verification\\nhttps://coolgirls.com")
         (t
          "Best regards,\\nMike Simka\\nElias Ecosystem\\nhttps://elias.garden"))))

;; Key bindings
(global-set-key (kbd "C-x m") 'mu4e)
(global-set-key (kbd "C-x M") 'mu4e-compose-new)

;; Provide the configuration
(provide 'mu4e-elias-config)

;;; mu4e-elias-config.el ends here
EOF

echo "✅ mu4e Emacs configuration created"

# Create initial mail sync and indexing
echo ""
echo "📬 Performing initial mail sync and indexing..."

echo "This may take a few minutes depending on email volume..."

# Initial sync
if command -v $SYNC_TOOL &> /dev/null; then
    echo "🔄 Syncing emails with $SYNC_TOOL..."
    $SYNC_TOOL --dry-run 2>/dev/null || echo "⚠️  Dry run completed (errors expected on first run)"
    
    echo "🔄 Performing actual sync..."
    $SYNC_TOOL || echo "⚠️  Some sync errors are normal on first run"
else
    echo "❌ $SYNC_TOOL not available"
fi

# Initialize mu database
echo "🗂️  Initializing mu database..."
mu init --maildir=~/Maildir --my-address=mike@elias.garden --my-address=mike@vocatar.com --my-address=mike@coolgirls.com

# Index emails
echo "📇 Indexing emails..."
mu index

echo "✅ Mail sync and indexing completed"

# Create startup script
echo ""
echo "🚀 Creating startup script..."

cat > ~/constellation/scripts/start-mu4e.sh << 'EOF'
#!/bin/bash
# Start mu4e email workflow

echo "📧 Starting Elias mu4e email workflow..."

# Sync emails
echo "🔄 Syncing emails..."
offlineimap --quick

# Update mu index
echo "📇 Updating email index..."
mu index

# Start Emacs with mu4e
echo "🎯 Starting Emacs with mu4e..."
emacs -l ~/constellation/shared/configs/email/mu4e-elias-config.el -f mu4e
EOF

chmod +x ~/constellation/scripts/start-mu4e.sh

echo "✅ Startup script created: ~/constellation/scripts/start-mu4e.sh"

# Create email tasks org file
mkdir -p ~/constellation/shared/todos
touch ~/constellation/shared/todos/email-tasks.org

cat > ~/constellation/shared/todos/email-tasks.org << 'EOF'
#+TITLE: Email Tasks
#+STARTUP: overview

* Email Tasks
  Email-derived tasks from mu4e integration

** TODO Setup Instructions
   Complete mu4e setup and test email workflow
   
** Configuration
   - [ ] Test email sending from all accounts
   - [ ] Verify email receiving and sync
   - [ ] Test org-mode email linking
   - [ ] Test email-to-task conversion
EOF

echo "✅ Email tasks org file created"

# Display success message and next steps
echo ""
echo "🎉 mu4e Email Integration Setup Complete!"
echo "========================================"
echo ""
echo "📧 Configuration Summary:"
echo "  Mail Server: $MAIL_SERVER"
echo "  Sync Tool: $SYNC_TOOL"
echo "  Maildir: ~/Maildir"
echo "  Config: ~/constellation/shared/configs/email/mu4e-elias-config.el"
echo ""
echo "📋 Next Steps:"
echo "=============="
echo "1. Add mu4e config to your Emacs init file:"
echo "   (load-file \"~/constellation/shared/configs/email/mu4e-elias-config.el\")"
echo ""
echo "2. Start mu4e workflow:"
echo "   ~/constellation/scripts/start-mu4e.sh"
echo ""
echo "3. Test email functionality:"
echo "   - Send test emails from each account"
echo "   - Verify email-to-task conversion"
echo "   - Test platform-specific signatures"
echo ""
echo "4. Set up automated sync (optional):"
echo "   Add to crontab: */5 * * * * $SYNC_TOOL --quick"
echo ""
echo "🔧 Key Commands in mu4e:"
echo "  C-x m     - Open mu4e"
echo "  C-x M     - Compose new email"
echo "  C-c C-c   - Send email"
echo "  j         - Jump to mailbox"
echo "  s         - Search emails"
echo "  U         - Update mail"
echo ""
echo "✨ Elias email workflow ready!"
echo "   Professional email management with org-mode integration"