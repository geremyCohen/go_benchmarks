#!/usr/bin/env bash

set -e  # Exit on any error
set -o pipefail

##########
# Detect OS
OS=$(uname -s)

##########
# Function to set up pyenv in the current shell
setup_pyenv_env() {
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
}

##########
# OS-specific installation
if [ "$OS" = "Darwin" ]; then
  echo "Detected macOS, installing with Homebrew..."

  # Update Homebrew
  brew update

  # Install packages if not already installed
  for package in pyenv virtualenv pyenv-virtualenv; do
    if which $package &>/dev/null || brew list $package &>/dev/null; then
      echo "$package is already installed"
    else
      echo "Installing $package..."
      brew install $package
    fi
  done
  
  # Check for gcloud and install if not present
  if ! which gcloud &>/dev/null; then
    echo "Installing Google Cloud SDK..."
    brew install --cask google-cloud-sdk
  else
    echo "Google Cloud SDK is already installed"
  fi

  # Set up pyenv for current shell
  setup_pyenv_env

elif [ "$OS" = "Linux" ]; then
  echo "Detected Linux, installing with apt-get..."

  # Update and install dependencies
  sudo apt-get -y update
  sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev git apt-transport-https ca-certificates gnupg

  # Check for gcloud and install if not present
  if ! which gcloud &>/dev/null; then
    echo "Installing Google Cloud SDK..."
    # Add the Cloud SDK distribution URI as a package source
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    # Import the Google Cloud public key
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    # Update and install the Cloud SDK
    sudo apt-get update && sudo apt-get install -y google-cloud-sdk
  else
    echo "Google Cloud SDK is already installed"
  fi

  # Install pyenv if not present
  if which pyenv &>/dev/null; then
    echo "pyenv is already installed"
  else
    echo "Installing pyenv..."
    curl https://pyenv.run | bash

    # Add to ~/.bashrc
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
  fi

  # Set up pyenv for current shell
  setup_pyenv_env

else
  echo "Unsupported operating system: $OS"
  echo "Please install pyenv manually for your system."
  exit 1
fi

##########
# Python environment setup

# Install Python version (skip if already installed)
if pyenv versions --bare | grep -q "^3.9.22$"; then
  echo "Python 3.9.22 is already installed"
else
  echo "Installing Python 3.9.22..."
  pyenv install 3.9.22
fi

# Create virtualenv if it doesn't exist
if pyenv virtualenvs --bare | grep -q "^rexec-sweet-env$"; then
  echo "Virtualenv rexec-sweet-env already exists"
else
  echo "Creating virtualenv rexec-sweet-env..."
  pyenv virtualenv 3.9.22 rexec-sweet-env
fi

##########
# Clone project and install dependencies

if [ ! -d "go_benchmarks" ]; then
  git clone https://github.com/geremyCohen/go_benchmarks.git
fi

cd go_benchmarks
pyenv local rexec-sweet-env

echo "Installing Python dependencies..."
pip install -e .

##########
# Generate SSH keys for Google Compute Engine without passphrase
echo "Generating SSH keys for Google Compute Engine..."
SSH_DIR="$HOME/.ssh"
GCE_KEY="$SSH_DIR/google_compute_engine"

# Create .ssh directory if it doesn't exist
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Generate SSH key without passphrase if it doesn't exist
if [ ! -f "$GCE_KEY" ]; then
  ssh-keygen -t rsa -f "$GCE_KEY" -N "" -C "$USER"
  chmod 600 "$GCE_KEY"
  chmod 644 "$GCE_KEY.pub"
  echo "SSH keys generated successfully."
else
  echo "SSH keys already exist."
fi

##########
# Final auth step
echo "Running gcloud auth login..."
gcloud auth login --no-launch-browser

# Check if project is set and let user select if not
echo "Checking GCP project configuration..."
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
if [ -z "$CURRENT_PROJECT" ] || [ "$CURRENT_PROJECT" = "(unset)" ]; then
  echo "No project currently set. Fetching available projects..."
  
  # Get all available projects in a way compatible with both bash and zsh, sorted alphabetically
  PROJECTS=$(gcloud projects list --format="value(projectId)" | sort)
  PROJECT_COUNT=$(echo "$PROJECTS" | wc -l | tr -d ' ')
  
  if [ "$PROJECT_COUNT" -eq 0 ]; then
    echo "No projects found. Please set a project manually with: gcloud config set project PROJECT_ID"
  else
    echo "Available projects:"
    PROJECT_NUM=1
    echo "$PROJECTS" | while read -r PROJECT; do
      echo "$PROJECT_NUM. $PROJECT"
      PROJECT_NUM=$((PROJECT_NUM + 1))
    done
    
    # Ask user to select a project
    while true; do
      printf "Enter number (1-%s) to select your default project: " "$PROJECT_COUNT"
      read CHOICE
      if [ "$CHOICE" -ge 1 ] 2>/dev/null && [ "$CHOICE" -le "$PROJECT_COUNT" ] 2>/dev/null; then
        SELECTED_PROJECT=$(echo "$PROJECTS" | sed -n "${CHOICE}p")
        echo "Setting project to $SELECTED_PROJECT"
        gcloud config set project "$SELECTED_PROJECT"
        break
      else
        echo "Invalid selection. Please enter a number between 1 and $PROJECT_COUNT."
      fi
    done
  fi
else
  echo "Using project: $CURRENT_PROJECT"
fi

# Force new shell with pyenv to continue
if [ "$OS" = "Darwin" ]; then
  exec zsh --login
else
  exec bash --login
fi
