#!/bin/bash

# Install xclip for clipboard functionality
echo "Checking for xclip installation..."
if ! command -v xclip &> /dev/null; then
  echo "xclip not found. Installing xclip..."
  sudo apt update && sudo apt install -y xclip
else
  echo "xclip is already installed."
fi

# Function to validate email
function validate_email() {
    if [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then
        return 0
    else
        echo "Invalid email format."
        return 1
    fi
}

# Prompt user for email and passphrase
read -p "Enter your email for the SSH key: " email
if ! validate_email "$email"; then
  exit 1
fi
read -s -p "Enter passphrase for the SSH key (optional, press Enter to skip): " passphrase
echo

# Select key type
echo "Available key types: 1) RSA 2) ECDSA 3) Ed25519"
read -p "Select key type (default RSA): " key_type
case $key_type in
    2) key_type="ecdsa"
       key_bits="521"  # ECDSA supports 256, 384, or 521 bits.
       ;;
    3) key_type="ed25519"
       key_bits=""
       ;;
    *) key_type="rsa"
       key_bits="4096"
       ;;
esac

# Generate SSH key
echo "Generating $key_type SSH key..."
ssh-keygen -t $key_type -b $key_bits -C "$email" -f ~/.ssh/id_rsa_$key_type -N "$passphrase"
if [ $? -ne 0 ]; then
    echo "Failed to generate SSH key."
    exit 1
fi

# Start the ssh-agent in the background
echo "Starting ssh-agent..."
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa_$key_type

# Display the SSH public key and attempt to copy it to clipboard
echo
echo "Your SSH public key is:"
cat ~/.ssh/id_rsa_$key_type.pub | tee /dev/clipboard
if command -v xclip &> /dev/null; then
    cat ~/.ssh/id_rsa_$key_type.pub | xclip -selection clipboard
    echo "The SSH public key has been copied to your clipboard."
else
    echo "Failed to copy to clipboard: xclip command not found."
fi

echo
echo "SSH key generation completed!"
echo "Remember to add your public key to the SSH keys in your version control systems."



