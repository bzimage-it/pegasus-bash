PEGASUS_START_SCRIPT_PWD="$PWD"
# this is a code snipped:
# from http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
# to understand what directory it's stored in bash script itself

# we use here 2 index here cause we assume that the caller of this fragment
# is the "import" script and its caller again is the final user script, so
# it is a 2 level:
_PEGASUS_source="${BASH_SOURCE[2]}"
while [ -h "$_PEGASUS_source" ]; do # resolve $SOURCE until the file is no longer a symlink
  _PEGASUS_dir="$( cd -P "$( dirname "$_PEGASUS_source" )" && echo "$PWD" )"
  _PEGASUS_source="$(readlink "$_PEGASUS_source")"
  [[ $_PEGASUS_source != /* ]] && _PEGASUS_source="$_PEGASUS_dir/$_PEGASUS_source" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
PEGASUS_SCRIPT_DIR="$( cd -P "$( dirname "$_PEGASUS_source" )" && echo "$PWD" )"
PEGASUS_SCRIPT_FILE="$(basename "$_PEGASUS_source")"
PEGASUS_SCRIPT_FULL="${PEGASUS_SCRIPT_DIR}/${PEGASUS_SCRIPT_FILE}"
# end of snipped
