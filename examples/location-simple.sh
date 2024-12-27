#!/bin/bash

# PEGASUS_BASH_ROOT shall be better set systemwide,
# e.g: in ~/.bashrc
# but we set manually here, just because is a demo:

# set only if not defined already (suitable for double call, see above)
PEGASUS_BASH_ROOT="$(readlink -f ..)"

PEGASUS_BASH_IMPORT_VERBOSE=0 # default is 0, do not write info during parse
source $PEGASUS_BASH_ROOT/pegasus-bash.sh location

echo
echo "my own canonical full name is: $PEGASUS_SCRIPT_FULL"
echo "my own canonical location is : $PEGASUS_SCRIPT_DIR"
echo "my own name is               : $PEGASUS_SCRIPT_FILE"


















