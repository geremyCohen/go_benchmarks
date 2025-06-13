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
# Final auth step
echo "Running gcloud auth login..."
gcloud auth login

# Force new shell with pyenv to continue
exec bash --login
