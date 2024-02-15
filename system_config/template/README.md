# System Configuration Template

This readme describes the [`sys_config.yaml`](sys_config.yaml) template in detail.

## Overview

The [`sys_config.yaml`](sys_config.yaml) is used by the [`sys_config.sh`](../sys_config.sh) script
to determine what services should be configured and how to configure them. The file defines service
configuration metadata, telling the `sys_config` script what service specific configuration files
need to be created and what command to use to create these files with the appropriate argument
information for the command.

## System Configuration Template Components

The template is comprised of three major parts, the `services` array, `out_dir` field, and
`services metadata` list:

### Services Array:

```yaml
services: []
```

This is a simple array where you will add the names of each service to configure. Each name is
correlated with the [`Service Metadata`](#service-metadata). An example with two services is:

```yaml
services: ["service1", "service2"]
```

### Output Directory:

```yaml
output_dir: <<value>>
```

This is a path to the directory where the configuration files should be placed. Each service
will get their own sub_directory (named the same as the name used in the
[`Services Array`](#services-array)). The path can be relative to the path where the
[`sys_config.sh`](../sys_config.sh) script is run or an absolute path. An absolute path is
generally preferred if the sys_config.sh script may be run from an unknown location. An example of
an absolute path is:

```yaml
output_dir: /home/userA/system_config
```

### Service Metadata:

```yaml
`service_name`:
  - template: <<value>>
    command: <<value>>
    args:
      - arg: <<value>>
        params: []
        optional: <<true|false>>
```

For each service defined in the [`Services Array`](#services-array) there is an associated metadata
object with the same `service_name` that was used in the services array. This metadata object is
comprised of one or more config objects. The config object is comprised of a `template`, `command`,
and `args` list:

#### Template Field

```yaml
- template: <<value>>
```

The template field is a path to the relevant service config template file. The path can be relative
to the path where the [`sys_config.sh`](../sys_config.sh) script is run or an absolute path. An
absolute path is generally preferred if the sys_config.sh script may be run from an unknown
location.

An example pointing to a config template for `service_1` is:

```yaml
- template: /home/userA/service_1/config/template/svc_config.yaml
```

#### Command Field

```yaml
command: <<value>>
```

The command field is a path to the relevant service config script. The path can be relative to the
path where the [`sys_config.sh`](../sys_config.sh) script is run or an absolute path. An absolute
path is generally preferred if the sys_config.sh script may be run from an unknown location. The
config script will handle creating the appropriate service configuration with any common parameters
passed to the system config script via the params file. A simple yaml find and replace params
script is provided in this repo [here](../scripts/replace_params_yaml.sh) and can work for most
basic yaml config files.

An example pointing to the `replace_params_yaml.sh` script:

```yaml
command: /home/userA/chariott-examples-applications/system_config/scripts/replace_params_yaml.sh
```

>Note: Any custom script can be used here if the `replace_params_yaml.sh` script is not sufficient.

#### Args List Field

```yaml
args:
  - arg: <<value>>
    params: []
    optional: <<true|false>>
```

The argument list is a set of argument metadata that tells the [`sys_config.sh`](../sys_config.sh)
script what arguments to pass to the config script defined in the [`command field`](#command-field)
.

##### Arg Field

The `arg` field is a string defining an argument. The `arg` field could have just a flag:

```yaml
- arg: "-i"
```

Or can include a flag and a value:

```yaml
- arg: "--param param_1"
```

Or can even be just a value depending on what the `command` script expects:

```yaml
- arg: "param_1"
```

If an argument string contains `{}` with a number (starting from `1`), the `sys_config` script will
attempt to replace the placeholder with a value defined in in the [`params array`](#params-array).

```yaml
- arg: "-p param_1={1}"
```

##### Params Array

The `params` array is a list of parameters to extract from a `params.yaml` file passed to the
[`sys_config.sh`](../sys_config.sh) script. The script will also check to see if the param name is
set as a variable in the `sys_config` script. An example of this is the `out_file` variable which
is a variable generated at script runtime and is not present in the `params.yaml` file. The
extracted parameter values are inserted into the `arg` field, replacing the placeholders in the
string.

Given an example `params.yaml` file:

```yaml
service_1_uri: "service_1://uri"
service_2_uri: "service_2://uri"
```

And an `arg` object entry of:

```yaml
- arg: "-p service_uri={1}"
  params: ["service_1_uri"]
  optional: false
```

The argument snippet would be compiled as:

```shell
command_script.sh -p service_uri=service_1://uri
```

##### Optional Field

The `optional` field can either be `true` or `false`. If set to `false` the `sys_config` script
will fail if one of the parameters in the [`params array`](#params-array) cannot be found. If set
to `true` then a parameter is not found in the `params.yaml` file the argument is just skipped.

## Examples

An example [`sys_config.yaml`](sys_config.yaml) creating a system with a single service called
`service1`:

```yaml
services: ["service1"]

output_dir: /home/userA/system_config

service1:
  - template: /home/userA/service_1/config/template/svc_config.yaml
    command: /home/userA/chariott-examples-applications/system_config/scripts/replace_params_yaml.sh
    args:
    - arg: "--file {1}"
        params: ["out_file"]
        optional: false
    - arg: "--param service_uri={1}"
        params: ["service_1_uri"]
        optional: false
    - arg: "--param service_version={1}"
        params: ["service_1_version"]
        optional: true
```
>Note: The `out_file` is a variable created by the `sys_config` script at runtime but can still be
referenced here.

Associated `params.yaml` file:

```yaml
service_1_uri: "example://uri"
# service_1_version: "0.1.0" # This parameter is optional.
```
