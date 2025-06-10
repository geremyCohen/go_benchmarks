# rexec_sweet - Remote Sweet Benchmark Execution Tool

This repo serves as a home to the `rexec_sweet` tool, which is designed to run Go benchmarks using the Sweet benchmarking tool on remote Google Cloud Platform (GCP) instances. It automates the process of setting up GCP instances, running benchmarks, and generating reports for comparison.

Please read all the instructions available in the official Arm Learning Path [Go Benchmarks with Sweet](https://developer.arm.com/learning-paths/servers-and-cloud-computing/go-benchmarking-with-sweet/) for complete details on how to use this tool effectively.

## Installation - Python Environment Setup

Please follow the instructions below to set up your Python environment using `pyenv` and `virtualenv` based on your local machine's OS.

### macOS
If you are on macOS, you can use Homebrew to install `pyenv`:

```bash
brew update
brew install pyenv
```

### Linux (Debian/Ubuntu)
On Linux, you can install `pyenv` and its dependencies using the following commands. This example uses `apt-get` for Debian/Ubuntu flavors, but you can adapt it for your specific distribution (e.g., `yum`, `dnf`, etc.).

```bash
sudo apt-get -y update

sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev git

curl https://pyenv.run | bash
```

### All OSes:  Add to your shell configuration (.bashrc, .zshrc, etc.)

Once you have installed `pyenv`, you need to add it to your shell configuration file. This example uses `.bashrc`, but you can adapt it for your shell (e.g., `.zshrc` for Zsh).

```bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
source ~/.bashrc
```

### All OSes:  Setting up Python 3.9.22 with pyenv and virtualenv

Setup a 3.9.22 environment with pyenv and virtualenv to make sure you run it against a tested Python version.

```bash

# Install Python 3.9.22
pyenv install 3.9.22

# Create a virtualenv for this project
pyenv virtualenv 3.9.22 rexec-sweet-env

# Clone the repository and set the local pyenv version
git clone https://github.com/geremyCohen/go_benchmarks.git
cd go_benchmarks
pyenv local rexec-sweet-env
```

#### Installing the package
You should already be in the `go_benchmarks` directory after the last step. Now, you can install the `rexec_sweet` package in editable mode.
```bash
# Install from the project directory
pip install -e .
```

## Usage

### Auth with GCP
Run the following command to authenticate with GCP.  This will open a browser window to log in with your Google account.

```bash
gcloud auth login
```
> [!IMPORTANT]
> If you get SSH warnings about key files or creating directories for SSH keys, choose "Yes" to create the directories and keys.  This is required for the tool to work properly. When asked for passphrases, you can leave them blank by pressing Enter.


### Running Benchmarks
```bash
# Run the tool
rexec-sweet
```
## Running Tests

```bash
# Install development dependencies
make dev

# Run tests
make test

# Run tests with coverage
make test-cov
```

## Requirements

- Python 3.9+
- Google Cloud SDK
- Go with benchstat tool installed
- Sweet benchmarking tool
