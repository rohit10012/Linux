#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Prompt for the username
read -p "Enter the username for the new sudo user: " username

# Create the user
useradd -m -s /bin/bash $username

# Set the password for the user
passwd $username

# Add the user to the sudoers file
echo "$username ALL=(ALL) ALL" >> /etc/sudoers

# Open the SSH configuration file
ssh_config="/etc/ssh/sshd_config"
cp "$ssh_config" "$ssh_config.bak"

# Uncomment the line that allows password authentication
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' "$ssh_config"

# Restart the SSH service
if [[ -x "$(command -v systemctl)" ]]; then
   systemctl restart sshd
else
   service ssh restart
fi

echo "Sudo user '$username' has been created successfully."
echo "Password-based login has been enabled."

