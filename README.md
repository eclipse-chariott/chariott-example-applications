# Eclipse Chariott Incubator - Example Vehicle Applications

- [Introduction](#introduction)
- [Examples](#examples)
  - [Dog mode](#dog-mode)
- [Getting Started](#getting-started)

## Introduction

This repository contains Eclipse Chariott example applications and integrations with other
components like [Eclipse Agemo](https://github.com/eclipse-chariott/Agemo),
[Eclipse Ibeji](https://github.com/eclipse-ibeji/ibeji), and
[Eclipse Freyja](https://github.com/eclipse-ibeji/freyja). It also serves as a place to incubate
early ideas for an eventual blueprint.

## Getting Started

### Prerequisites

This guide uses `apt` as the package manager in the examples. You may need to substitute your own
package manager in place of `apt` when going through these steps.

1. Install gcc:

    ```shell
    sudo apt install gcc
    ```

    > **NOTE**: Rust needs gcc's linker.

1. Install git and git-lfs

    ```shell
    sudo apt install -y git git-lfs
    git lfs install
    ```

1. Install [rust](https://rustup.rs/#), using the default installation, for example:

    ```shell
    sudo apt install curl
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    ```

    You will need to restart your shell to refresh the environment variables.

    > **NOTE**: The rust toolchain version is managed by the rust-toolchain.toml file, so once you
                install rustup there is no need to manually install a toolchain or set a default.

1. Install OpenSSL:

    ```shell
    sudo apt install pkg-config
    sudo apt install libssl-dev
    ```

1. Install Protobuf Compiler:

    ```shell
    sudo apt install -y protobuf-compiler
    ```

    > **NOTE**: The protobuf compiler is needed for building the project.

### Cloning the Repo

The repo has a submodule [chariott](https://github.com/eclipse-chariott/chariott) that provides
proto files for Chariott Intent Brokering integration. To ensure that these files are included,
please use the following command when cloning the repo:

```shell
git clone --recurse-submodules https://github.com/eclipse-chariott/chariott-example-applications
```

### Building

Run the following to build everything in the workspace once you have installed the prerequisites:

```shell
cargo build --workspace
```

### Running the Tests

After successfully building the service, you can run all of the unit tests. To do this go to the
enlistment's root directory and run:

```shell
cargo test
```

## Examples

### Dog mode

The [dog mode](./intent_brokering/dogmode/README.md) allows a car owner to keep their dog safe while they are away
from the car. If the ambient temperature is high, multiple different applications will interact
with each other to ensure that the temperature inside the car is at a safe level for the dog. This
example currently uses Eclipse Chariott and is in design and development to integrate with other
Eclipse Software Defined Vehicle projects.
