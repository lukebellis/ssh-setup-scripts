#!/bin/bash

# Install xclip for clipboard functionality
echo "Checking for xclip installation..."
if ! command -v xclip &> /dev/null; then
    echo "xclip not found. Installing xclip..."
    sudo apt update && sudo apt install -y xclip
else
    echo "xclip is already installed."
fi

# Prompt user for email, passphrase, and custom filename
read -p "Enter your email for the SSH key: " email
read -s -p "Enter passphrase for the SSH key (optional, press Enter to skip): " passphrase
echo
read -p "Enter filename for the SSH key (e.g., id_rsa_bitbucket_username): " ssh_key_filename

# Generate SSH key
echo "Generating SSH key..."
ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/$ssh_key_filename -N "$passphrase"

# Start the ssh-agent in the background
echo "Starting ssh-agent..."
eval "$(ssh-agent -s)"

# Add SSH key to the ssh-agent
echo "Adding SSH key to ssh-agent..."
ssh-add ~/.ssh/$ssh_key_filename

# Copy SSH public key to clipboard
echo
echo "Your SSH public key is:"
cat ~/.ssh/$ssh_key_filename.pub | tee /dev/clipboard | xclip -selection clipboard
echo "The SSH public key has been copied to your clipboard."

# Configure SSH for Bitbucket
read -p "Enter your Bitbucket username: " bitbucket_user
echo "Configuring SSH for Bitbucket..."
echo "
Host bitbucket.org-$bitbucket_user
    HostName bitbucket.org
    User git
    IdentityFile ~/.ssh/$ssh_key_filename
    IdentitiesOnly yes" >> ~/.ssh/config

# Option to add SSH key to Bitbucket using the API
read -p "Do you want to add this SSH key to your Bitbucket account? (y/n): " add_to_bitbucket
if [[ $add_to_bitbucket =~ ^[Yy]$ ]]; then
    read -s -p "Enter your Bitbucket App password (with 'Account: Write' permission): " bitbucket_password
    echo
    ssh_key=$(cat ~/.ssh/$ssh_key_filename.pub)
    description="SSH key for $(hostname) - $bitbucket_user"

    echo "Adding SSH key to your Bitbucket account..."
    response=$(curl -s -u "$bitbucket_user:$bitbucket_password" -X POST \
        -H "Content-Type: application/json" \
        -d "{\"label\": \"${description}\", \"key\": \"${ssh_key}\"}" \
        "https://api.bitbucket.org/2.0/users/$bitbucket_user/ssh-keys")
    if echo "$response" | grep -q "created_on"; then
        echo "SSH key has been added to your Bitbucket account."
    else
        echo "Failed to add SSH key to your Bitbucket account. Response: $response"
    fi
fi

echo
echo "SSH key generation and configuration completed!"
