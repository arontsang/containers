#!/bin/sh

# Create Dropbear host key directory
mkdir -p /etc/dropbear

# Generate unique Dropbear host keys if they do not exist
if [ ! -f "/etc/dropbear/dropbear_rsa_host_key" ]; then
    dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key
fi
if [ ! -f "/etc/dropbear/dropbear_ed25519_host_key" ]; then
    dropbearkey -t ed25519 -f /etc/dropbear/dropbear_ed25519_host_key
fi

# Fallback username if missing
SCP_USER=${SCP_USER:-scpuser}

# Create the user without a password, with standard shell access for SCP
if ! id -u "$SCP_USER" > /dev/null 2>&1; then
    adduser -D -h "/home/$SCP_USER" -s /bin/sh "$SCP_USER"
    # Lock password login for this account
    passwd -l "$SCP_USER"
fi

# Set up the .ssh directory and data storage folder
USER_HOME="/home/$SCP_USER"
mkdir -p "$USER_HOME/.ssh" "$USER_HOME/data"

# Inject the public key if provided via environment variable
if [ -n "$SSH_PUBLIC_KEY" ]; then
    echo "$SSH_PUBLIC_KEY" > "$USER_HOME/.ssh/authorized_keys"
else
    echo "WARNING: No SSH_PUBLIC_KEY provided. Access will be blocked."
fi

# Enforce strict permission requirements for SSH keys
chown -R "$SCP_USER:$SCP_USER" "$USER_HOME"
chmod 700 "$USER_HOME/.ssh"
if [ -f "$USER_HOME/.ssh/authorized_keys" ]; then
    chmod 600 "$USER_HOME/.ssh/authorized_keys"
fi

# Launch Dropbear in the foreground
# -F : Run in foreground
# -E : Log to standard error
# -p : Bind to port 22
# -s : Disable password logins entirely (keys only)
# -g : Disable password logins for root as well
exec dropbear -F -E -p 22 -s -g
