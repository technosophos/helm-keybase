# Helm Keybase

This plugin provides [Keybase](https://keybase.io) services to Helm.

The plugin is designed to make it easy for you to do three things:

- Host your chart repo on Keybase. Here's my [example repo](https://technosophos.keybase.pub/charts/)
- Sign charts with your Keybase key
- Verify charts with your Keybase keyring


## Installation

This requires that you have installed the Keybase command line client.

```console
$ helm plugin install https://github.com/technosophos/helm-keybase
```

## Usage

The basic commands are:

- `helm keybase help`: Print help text
- `helm keybase push`: Push your chart to your local mount of the keybase file system.
- `helm keybase sign`: Sign a chart with your keybase identity.
- `helm keybase verify`: Verify a chart with your keybase keyring.
