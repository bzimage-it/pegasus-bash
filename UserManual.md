% pegasus-bash(3) | Pegasus Bash User Manual

NAME
====

pegasus-bash - library of different utilities and iprovements in bash shell.

SYNOPSIS
========

!/bin/bash

PEGASUS_BASH_ROOT=$HOME/my/pegasus/bash/installation/dir

source $PEGASUS_BASH_ROOT/pegasus-bash.sh [*PACKAGE1* [*PACKAGE2* ..]]

DESCRIPTION
===========

You should include via 'source' or '.' bash command single packages.

It provides following *PACKAGES*:

* ```log```: a powerfull logging API with log levels, colors, custom formatting, writes to different output descriptors

* ```param2env``` : maps command line parameters to ordinary environment variables, likes ```env(1)``` command. A valid alternarnavite to classic '''getopt''' or '''--option''' style cli.

* ```location``` : knows where its own script is located, regardless of symlinks.

* ```temp``` : provides temporary files via ```mktemp(1)```, hold names in order to be remoted at exit; the programmer can forget names and call a cleanup method when exit

* ```debug``` : provides ```assert()``` function, bash strack and unix stack trace dump 

IMPORT
=======

In order to import one or more *PACKAGES* you should:

1. define PEGASUS_BASH_ROOT to point to the root directory where program is installed. A file named ```pegaso-bash.sh``` shall be present there. You can do that at the very beginnig of your script or export it in your bash initialization file, for example ```.bashrc```.
2. execute a *source* command to import:
```$PEGASUS_BASH_ROOT/pegasus-bash.sh```
followed by one or more *PACKAGES* indicating the list packages to be used by the script

log package API
===============

Overview
--------





`-h, --help`

:   Show the help message and exit

`-c, --cli WALLPAPER_PATHS...`

:   Set wallpapers from the command line

`-m, --modes WALLPAPER_MODES...`

:   Specify the modes for the wallpapers (`zoom`, `center_black`, `center_blur`, `fit_black`, `fit_blur`)

`-r, --random`

:   Set wallpapers randomly

`-l, --lockscreen`

:   Set lockscreen wallpapers instead of desktop ones (for supported desktop environments)

BUGS
====

Bugs can be reported and filed at https://gitlab.gnome.org/gabmus/hydrapaper/issues

If you are not using the flatpak version of HydraPaper, or if you are using an otherwise out of date or downstream version of it, please make sure that the bug you want to report hasn't been already fixed or otherwise caused by a downstream patch.





#+begin_src sh

#+end_src sh

