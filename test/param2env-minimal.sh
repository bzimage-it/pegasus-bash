
# first param is that one to print, get it:
VARNAME="$1"
shift

source "$PEGASO_BASH_ROOT"/pegaso-bash.sh param2env

eval echo \$$VARNAME
