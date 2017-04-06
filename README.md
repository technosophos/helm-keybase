# Helm Plugins

This repository contains several Helm plugins, along with an installation script.

## Plugins

- `keybase`: Provide Keybase integration to Helm
- `github`: Provide GitHub integration to Helm
- `env`: Display the environment passed to a plugin.
- `hello`: An example of a basic Helm plugin

## Installation

1. Set HELM_HOME: `export HELM_HOME=$(helm home)`
2. Run `make install`.

## Usage

- Run `helm help` to see the new plugins.
- Run `helm keybase --help` for keybase help.
- Run `helm github --help` for github help.
