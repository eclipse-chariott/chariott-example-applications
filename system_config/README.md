# System Configuration Example

This example shows how a system comprised of multiple services might utilize a common configuration
despite each service having different configuration file conventions. The example provides a system
configuration script ([`sys_config.sh`](./scripts/sys_config.sh)) and a yaml replacement script
([`replace_params_yaml.sh`](./scripts/replace_params_yaml.sh)). The `sys_config` script is flexible
and can accept custom script implementations for a service that requires configuration steps beyond
config file generation or do not use yaml.

## Setup

### Install yq

Currently the only requirement for running the [`sys_config.sh`](./scripts/sys_config.sh) script is
that `yq` is installed. To install yq run:

```shell
sudo apt update
sudo apt install -y snapd
sudo snap install yq
```

## Running the System Configuration Script

From the root of the project run:

```shell
./system_config/scripts/sys_config.sh -c ./system_config/sys_config.yaml -p ./system_config/params.yaml
```

This will output config files to `./system_config/out_dir` under the respective service sub
directories.

## Script Inputs

The `sys_config` script takes in a configuration file and a parameters file to construct a set of
configuration files for defined services with common values in the parameters file.

### System Configuration File

The system configuration file describes the set of services to configure, where to place the
generated service config files and how to compile the service config files.

See [`System Configuration Template`](./template/README.md#system-configuration-template) for
details on the separate fields in the template and how to fill the config file out.

An example can be found here: [`sys_config.yaml`](./sys_config.yaml).

### Params File

The params file is a simple set of name value pairs that are common amongst some or all of the
services being configured.

An example can be found here: [`params.yaml`](./params.yaml).

## FAQ

1. <b>Q</b>: I changed a value in the common `params.yaml` file. What should I do?

    <b>A</b>: If a change has been made to common parameter you should re-run the `sys_config.sh` script
    to regenerate the service configuration files.

1. <b>Q</b>: How do I add a new service to the system configuration?

    <b>A</b>: There are 3 steps for adding a new service to the system configuration:
    
    1. Add the service name to the `services` array in `sys_config.yaml`.
    1. Add a new service metadata object (as defined in
    [`service metadata`](./template/README.md#service-metadata)).
    1. Update the `params.yaml` file with any new common parameters.
