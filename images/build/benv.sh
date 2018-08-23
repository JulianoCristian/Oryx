#!/bin/bash
if [ -n "$BENV_DEBUG" ]; then
  unset BENV_DEBUG
  set -x
fi

versions() {
  cd "$1"
  IFS=$' \t\n'
  for version in $(ls); do
    LINK=$(readlink "$version")
    if [ -z "$LINK" ]; then
      echo "  "$version
    else
      echo "  "$version -\> $LINK
    fi
  done
}

# Read inline environment
while true; do
  if [[ $1 = *"="* ]]; then
    eval export "$1"
    shift
  else
    break
  fi
done

# Save npm versions
_npm="$npm"
IFS='='
while read name value; do
  eval _$name="$value"
done < <(env | grep ^npm_)
IFS=$' \t\n'

# Resolve node versions
if [ -n "$node" -a "${node::1}" != "/" ]; then
  if [ ! -d "/opt/nodejs/$node" ]; then
    echo >&2 benv: node version \'$node\' not found\; choose one of:
    versions /opt/nodejs >&2
    exit 1
  fi
  DIR=/opt/nodejs/$node/bin
  export PATH=$DIR:$PATH
  export node=$DIR/node
  export npm=$DIR/npm
  if [ -e "$DIR/npx" ]; then
    export npx=$DIR/npx
  fi
fi
IFS='='
while read name value; do
  name=${name:5}
  if [ "${value::1}" == "/" ]; then
    continue
  fi
  if [ ! -d "/opt/nodejs/$value" ]; then
    echo >&2 benv: node version \'$value\' not found\; choose one of:
    versions /opt/nodejs >&2
    exit 1
  fi
  DIR=/opt/nodejs/$value/bin
  eval export node_$name=$DIR/node
  eval export npm_$name=$DIR/npm
  if [ -e "$DIR/npx" ]; then
    eval export npx_$name=$DIR/npx
  fi
done < <(env | grep ^node_)
IFS=$' \t\n'

# Resolve npm versions
if [ -n "$_npm" -a "${_npm::1}" != "/" ]; then
  if [ ! -d "/opt/npm/$_npm" ]; then
    echo >&2 benv: npm version \'$_npm\' not found\; choose one of:
    versions /opt/npm >&2
    exit 1
  fi
  DIR=/opt/npm/$_npm
  export PATH=$DIR:$PATH
  export npm=$DIR/npm
  if [ -e "$DIR/npx" ]; then
    export npx=$DIR/npx
  fi
fi
IFS='='
while read name value; do
  name=${name:5}
  if [ "${value::1}" == "/" ]; then
    continue
  fi
  if [ ! -d "/opt/npm/$value" ]; then
    echo >&2 benv: npm version \'$value\' not found\; choose one of:
    versions /opt/npm >&2
    exit 1
  fi
  DIR=/opt/npm/$value
  eval export npm_$name=$DIR/npm
  if [ -e "$DIR/npx" ]; then
    eval export npx_$name=$DIR/npx
  fi
done < <(set | grep ^_npm_)
IFS=$' \t\n'

# Resolve python versions
if [ -n "$python" -a "${python::1}" != "/" ]; then
  if [ ! -d "/opt/python/$python" ]; then
    echo >&2 benv: python version \'$python\' not found\; choose one of:
    versions /opt/python >&2
    exit 1
  fi
  DIR=/opt/python/$python/bin
  export PATH=$DIR:$PATH
  export pip=$DIR/pip
  if [ -e "$DIR/python2" ]; then
    export python=$DIR/python2
  elif [ -e "$DIR/python3" ]; then
    export python=$DIR/python3
  fi
  if [ -e "$DIR/virtualenv" ]; then
    export virtualenv=$DIR/virtualenv
  fi
fi
IFS='='
while read name value; do
  name=${name:7}
  if [ "${value::1}" == "/" ]; then
    continue
  fi
  if [ ! -d "/opt/python/$value" ]; then
    echo >&2 benv: python version \'$value\' not found\; choose one of:
    versions /opt/python >&2
    exit 1
  fi
  DIR=/opt/python/$value/bin
  eval export pip_$name=$DIR/pip
  if [ -e "$DIR/python2" ]; then
    eval export python_$name=$DIR/python2
  elif [ -e "$DIR/python3" ]; then
    eval export python_$name=$DIR/python3
  fi
  if [ -e "$DIR/virtualenv" ]; then
    eval export virtualenv_$name=$DIR/virtualenv
  fi
done < <(env | grep ^python_)
IFS=$' \t\n'

if [ $# -eq 0 ]; then
  set -- env
fi
exec "$@"