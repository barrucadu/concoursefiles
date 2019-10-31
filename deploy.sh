#! /usr/bin/env bash

set -e

HOST="$1"

SECRETS="$HOME/secrets/concourse/params-$HOST.yml"
PIPELINES="$PWD/pipelines/$HOST"

if [[ ! -e "$SECRETS" ]]; then
  echo "Secrets file ($SECRETS) is missing" >&2
  exit 1
fi

function set_pipeline () {
  yml="$1"
  name="$(basename "$yml" | sed 's:.yml$::')"
  if [[ ! -e "$yml" ]]; then
    echo "Pipeline $yml is missing" >&2
  else
    yes | fly set-pipeline -t "$HOST" -p "$name" -c "$yml" -l "$SECRETS"
  fi
}

function initialise_concourse () {
  fly login -t "$HOST" -c "https://ci.$HOST.barrucadu.co.uk"

  set_pipeline pipelines/ci.yml

  fly unpause-pipeline -t "$HOST" -p ci
  fly trigger-job -t "$HOST" -j ci/ci-base
}

initialise_concourse

if [[ -d "$PIPELINES" ]]; then
  cd "$PIPELINES"

  for pipeline in *.yml; do
    set_pipeline "$pipeline"
  done

  echo
  echo "Concourse initialised and CI pipeline triggered."
  echo "Unpause other pipelines when CI pipeline is done."
else
  echo
  echo "Concourse initialised and CI pipeline triggered."
  echo "No other pipelines."
fi
