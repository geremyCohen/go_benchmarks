# rexec_sweet - Remote Sweet Benchmark Execution Tool

Please read all the instructions available in the official Arm Learning Path [Go Benchmarks with Sweet](https://developer.arm.com/learning-paths/servers-and-cloud-computing/go-benchmarking-with-sweet/) for complete details on how to use this repo.

This repo serves as a home to the `rexec_sweet` tool, which is designed to run Go benchmarks using the Sweet benchmarking tool on remote Google Cloud Platform (GCP) instances. It automates the process of setting up GCP instances, running benchmarks, and generating reports for comparison.


## Installation

Please see installation instructions in the [rexec_sweet_install.md](https://developer.arm.com/learning-paths/servers-and-cloud-computing/go-benchmarking-with-sweet/rexec_sweet_install.md) file.

## Usage

### Auth with GCP
The install script will prompt you to authenticate with Google Cloud Platform (GCP) using the `gcloud` command-line tool. If after installing you have issues running the script and/or get GCP authentication errors, you can manually authenticate by running the following command:

```bash
gcloud auth login
```

> [!IMPORTANT]
> If you get SSH warnings about key files or creating directories for SSH keys, choose "Yes" to create the directories and keys.  This is required for the tool to work properly. When asked for passphrases, you can leave them blank by pressing Enter.


### Running Benchmarks
After installation and authentication, you can run the `rexec-sweet` command to execute benchmarks on your GCP instances.

```bash
# Run the tool
rexec-sweet
```
## Tests (optional)
To run tests for the `rexec_sweet` tool, you can use the provided Makefile. This will ensure that all dependencies are installed and that the tests are executed correctly.

```bash
# Install development dependencies
make dev

# Run tests
make test

# Run tests with coverage
make test-cov
```

