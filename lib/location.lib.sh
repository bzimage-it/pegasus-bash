PEGASO_START_SCRIPT_PWD="$PWD"

# this is a code snipped:
# from http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
# to understand what directory it's stored in bash script itself

# we use here 2 index here cause we assume that the caller of this fragment
# is the "import" script and its caller again is the final user script, so
# it is a 2 level:
_PEGASO_source="${BASH_SOURCE[2]}"
while [ -h "$_PEGASO_source" ]; do # resolve $SOURCE until the file is no longer a symlink
  _PEGASO_dir="$( cd -P "$( dirname "$_PEGASO_source" )" && echo "$PWD" )"
  _PEGASO_source="$(readlink "$_PEGASO_source")"
  [[ $_PEGASO_source != /* ]] && _PEGASO_source="$_PEGASO_dir/$_PEGASO_source" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
PEGASO_SCRIPT_DIR="$( cd -P "$( dirname "$_PEGASO_source" )" && echo "$PWD" )"
PEGASO_SCRIPT_FILE="$(basename "$_PEGASO_source")"
PEGASO_SCRIPT_FULL="${PEGASO_SCRIPT_DIR}/${PEGASO_SCRIPT_FILE}"
# end of snipped
