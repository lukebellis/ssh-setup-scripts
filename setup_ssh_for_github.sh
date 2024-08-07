#!/bin/bash

# Function to check if running in WSL
is_wsl() {
  grep -qi microsoft /proc/version
}

# Function to check if running on macOS
is_macos() {
  [[ "$OSTYPE" == "darwin"* ]]
}

# Function to install xclip on Ubuntu
install_xclip_ubuntu() {
  echo "Checking for xclip installation..."
  if ! command -v xclip &> /dev/null; then
      echo "xclip not found. Installing xclip..."
      sudo apt update && sudo apt install -y xclip
  else
      echo "xclip is already installed."
  fi
}

# Function to install xclip on macOS
install_xclip_macos() {
  echo "Checking for xclip installation..."
  if ! command -v xclip &> /dev/null; then
      echo "xclip not found. Installing xclip..."
      brew install xclip
  else
      echo "xclip is already installed."
  fi
}

# Install xclip for clipboard functionality
if is_wsl; then
  install_xclip_ubuntu
elif is_macos; then
  install_xclip_macos
else
  install_xclip_ubuntu
fi

# Prompt user for email, passphrase, and custom filename
read -p "Enter your email for the SSH key: " email
read -s -p "Enter passphrase for the SSH key (optional, press Enter to skip): " passphrase
echo
read -p "Enter filename for the SSH key (e.g., id_rsa_github_username): " ssh_key_filename

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
cat ~/.ssh/$ssh_key_filename.pub

if is_wsl; then
  echo "Running in WSL. Copying SSH public key to Windows clipboard..."
  cat ~/.ssh/$ssh_key_filename.pub | clip.exe
elif is_macos; then
  echo "Running on macOS. Copying SSH public key to macOS clipboard..."
  cat ~/.ssh/$ssh_key_filename.pub | pbcopy
else
  cat ~/.ssh/$ssh_key_filename.pub | xclip -selection clipboard
fi

echo "The SSH public key has been copied to your clipboard."

# Configure SSH for GitHub
read -p "Enter your GitHub username: " github_user
echo "Configuring SSH for GitHub..."
echo "
Host github.com-$github_user
    HostName github.com
    User git
    IdentityFile ~/.ssh/$ssh_key_filename
    IdentitiesOnly yes" >> ~/.ssh/config

# Option to add SSH key to GitHub
read -p "Do you want to add this SSH key to your GitHub account? (y/n): " add_to_github
if [[ $add_to_github =~ ^[Yy]$ ]]; then
    read -s -p "Enter your GitHub personal access token (with admin:public_key permission): " github_token
    echo
    ssh_key=$(cat ~/.ssh/$ssh_key_filename.pub)
    description="SSH key for $(hostname) - $github_user"

    echo "Adding SSH key to your GitHub account..."
    response=$(curl -s -w "%{http_code}" -o /dev/null -X POST -H "Authorization: token $github_token" \
        -H "Content-Type: application/json" \
        -d "{\"title\":\"${description}\",\"key\":\"${ssh_key}\"}" \
        "https://api.github.com/user/keys")
    if [[ "$response" == "201" ]]; then
        echo "SSH key has been added to your GitHub account."
    else
        echo "Failed to add SSH key to your GitHub account. Response code: $response"
    fi
fi

echo
echo "SSH key generation and configuration completed!"
