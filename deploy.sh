#! /bin/sh

SECRETS=$HOME/secrets/concourse/params.yml

if [[ ! -e "$SECRETS" ]]; then
  echo "Secrets file ($SECRETS) is missing" >&2
  exit 1
fi

function set_pipeline () {
  pipeline="pipelines/$1.yml"
  if [[ ! -e "$pipeline" ]]; then
    echo "Pipeline $pipeline is missing" >&2
  else
    yes | fly set-pipeline -t dunwich -p "$1" -c "$pipeline" -l "$SECRETS"
  fi
}

function initialise_concourse () {
  fly login -t dunwich -c https://ci.dunwich.barrucadu.co.uk

  set_pipeline ci

  fly unpause-pipeline -t dunwich -p ci
  fly trigger-job -t dunwich -j ci/ci-base
}

initialise_concourse

set_pipeline barrucadu.co.uk
set_pipeline uzbl.org

echo
echo "Concourse initialised and CI pipeline triggered."
echo "Unpause other pipelines when CI pipeline is done."
