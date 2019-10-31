#! /bin/sh

HOST="$1"
PIPELINE="$2"

SECRETS="$HOME/secrets/concourse/params-$HOST.yml"
PIPELINES="$PWD/pipelines/$HOST"

if [[ ! -e "$SECRETS" ]]; then
  echo "Secrets file ($SECRETS) is missing" >&2
  exit 1
fi

yml="${PIPELINES}/${PIPELINE}.yml"
name="$(echo "$(basename $yml)" | sed 's:.yml$::')"

if [[ -e "$yml" ]]; then
  fly login -t "$HOST" -c "https://ci.$HOST.barrucadu.co.uk"
  yes | fly set-pipeline -t "$HOST" -p "$name" -c "$yml" -l "$SECRETS"

  echo
  echo "Pipeline deployed."
else
  echo "Pipeline ${PIPELINE} is missing" >&2
fi
