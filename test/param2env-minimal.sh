
# first param is that one to print, get it:
VARNAME="$1"
shift

source "$PEGASUS_BASH_ROOT"/pegasus-bash.sh param2env

eval echo \$$VARNAME
