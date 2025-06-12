# Detect OS
OS=$(uname -s)

# Install based on detected OS
if [ "$OS" = "Darwin" ]; then
  echo "Detected macOS, installing with Homebrew..."

  # Update Homebrew
  brew update

  # Check and install required packages
  for package in pyenv virtualenv pyenv-virtualenv; do
    if which $package &>/dev/null || brew list $package &>/dev/null; then
      echo "$package is already installed"
    else
      echo "Installing $package..."
      brew install $package
    fi
  done

elif [ "$OS" = "Linux" ]; then
  echo "Detected Linux, installing with apt-get..."

  # Update package lists
  sudo apt-get -y update

  # Install dependencies
  sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev git

  # Check if pyenv is already installed
  if which pyenv &>/dev/null; then
    echo "pyenv is already installed"
  else
    echo "Installing pyenv..."
    curl https://pyenv.run | bash
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
  fi

else
  echo "Unsupported operating system: $OS"
  echo "Please install pyenv manually for your system."
  exit 1
fi


# Install Python 3.9.22
source ~/.bashrc
pyenv install 3.9.22

# Create a virtualenv for this project
pyenv virtualenv 3.9.22 rexec-sweet-env

# Clone the repository and set the local pyenv version
git clone https://github.com/geremyCohen/go_benchmarks.git
cd go_benchmarks
pyenv local rexec-sweet-env

# Install from the project directory
pip install -e .


gcloud auth login
