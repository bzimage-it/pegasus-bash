
declare -A PEGASUS_VALID_ENV_PARAMS=(
    [A]=upstring
    [SOMEBOOL]=bool
    [ANOTHERBOOL]=bool
    [Directory]=dir
    [File]=file
    [aint]=int
    [auint]=uint
    [S]=string
)

declare -A PEGASUS_VALID_ENV_DEFAULT=(
    [A]=avalue
    [SOMEBOOL]=TRUE
    [ANOTHERBOOL]=FALSE
    [Directory]=.
    [File]=""
    [aint]="-4"
    [auint]=5
    [S]=__undef__
)

declare -A PEGASUS_VALID_ENV_HELP=(
    [A]="a string in uppercase"
    [SOMEBOOL]="an example of bool param: YES|Y|1|T|TRUE or 0|N|NO|F|FALSE"
    [ANOTHERBOOL]="another bool param"
    [Directory]="an existing directory"
    [File]="an existing file"
    [aint]="an integer with sign"
    [auint]="a positive integer"
    [S]="a generic string"
)


