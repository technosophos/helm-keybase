#!/bin/bash

set -eu

usage() {
cat << EOF
Keybase integration with Helm.

This provides tools for working with the Keybase.io secure tool suite.

Available Commands:
  push    Push a chart (repository) to a Keybase signed directory
  sign    Sign a chart archive (tgz file) with a Keybase key
  verify  Verify a chart archive (tgz + tgz.prov) with a Keybase key

EOF
}

push_usage() {
cat << EOF
Push a chart to a Keybase repo.

Example:
    $ helm keybase push foo-0.1.0.tgz

EOF
}

sign_usage() {
cat << EOF
Sign a chart using Keybase credentials.

This is an alternative to 'helm sign'. It uses your keybase credentials
to sign a chart.

Example:
    $ helm keybase sign foo-0.1.0.tgz

EOF
}

verify_usage() {
cat << EOF
Verify a chart

This is an alternative to 'helm verify'. It uses your keybase credentials
to verify a chart.

Example:
    $ helm keybase verify foo-0.1.0.tgz
    Signature verified. Signed by technosophos 1 day ago (2016-11-28 17:07:21 -0700 MST).
    PGP Fingerprint: aba2529598f6626c420d335b62f49e747d911b60.
    Chart SHA verified. sha256:62728732cc113510637a6ba4c318bc27e56cbb1d01166f5be03329e547d640c4

In typical usage, use 'helm fetch --prov' to fetch a chart:

    $ helm fetch --prov upstream/wordpress
    $ helm keybase verify wordpress-1.2.3.tgz
    $ helm install ./wordpress-1.2.3.tgz

EOF
}

is_help() {
  case "$1" in
  "-h")
    return 0
    ;;
  "--help")
    return 0
    ;;
  "help")
    return 0
    ;;
  *)
    return 1
    ;;
esac
}


push() {
  if is_help $1 ; then
    push_usage
    return
  fi

  u=$(kuser)
  chart=$1
  repo=/keybase/public/${u}/charts
  dest="https://${u}.keybase.pub/charts/"

  echo "Copying $chart to $repo"
  cp $chart $repo
  cp ${chart}.prov $repo
  helm repo index $repo --url $dest

  echo "Successfully pushed $1 to $dest"
}

sign() {
  if is_help $1 ; then
    sign_usage
    return
  fi
  chart=$1
  echo "Signing $chart"
  shasum=$(openssl sha -sha256 $chart| awk '{ print $2 }')
  chartyaml=$(tar -zxf $chart --exclude 'charts/' -O '*/Chart.yaml')
c=$(cat << EOF
$chartyaml

...
files:
  $chart: sha256:$shasum
EOF
)
  keybase pgp sign -c -o "$chart.prov" -m "$c"
}

verify() {
  if is_help $1 ; then
    verify_usage
    return
  fi
  chart=$1
  keybase pgp verify -i ${chart}.prov

  # verify checksum
  sha=$(shasum $chart)
  set +e
  grep "$chart: sha256:$sha" ${chart}.prov > /dev/null
  if [ $? -ne 0 ]; then
    echo "ERROR SHA verify error: sha256:$sha does not match ${chart}.prov"
    return 3
  fi
  set -e
  echo "Chart SHA verified. sha256:$sha"
}

shasum() {
  openssl sha -sha256 "$1" | awk '{ print $2 }'
}

kuser() {
  keybase status | grep "Username: " | awk '{ print $2 }'
}

if [[ $# < 1 ]]; then
  usage
  exit 1
fi

if ! type "keybase" > /dev/null; then
  echo "Command like 'keybase' client must be installed"
  exit 1
fi

case "${1:-"help"}" in
  "push")
    if [[ $# < 2 ]]; then
      push_usage
      echo "Error: Chart package required."
      exit 1
    fi
    push $2
    ;;
  "sign"):
    if [[ $# < 2 ]]; then
      push_usage
      echo "Error: Chart package required."
      exit 1
    fi
    sign $2
    ;;
  "verify"):
    if [[ $# < 2 ]]; then
      verify_usage
      echo "Error: Chart package required."
      exit 1
    fi
    verify $2
    ;;
  "help")
    usage
    ;;
  "--help")
    usage
    ;;
  "-h")
    usage
    ;;
  *)
    usage
    exit 1
    ;;
esac

exit 0
