# pegasus-bash
a Bash API improvement and enhancements with logging, debugging, command parameters and more.
* includes different modules to be imported via ```source(1)```
* ```log```: a powerful logging API with log levels, colors, custom formatting, writes to different output descriptors
* ```param2env``` : maps command line parameters to ordinary environment variables, likes ```env(1)``` command. A valid alternative to classic ```getopt``` or ```--option``` style cli.
* ```location``` : knows where its own script is located, regardless of symlinks ("canonization path")
* ```temp``` : provides temporary files via ```mktemp(1)```, hold names in order to be removed ones the script terminates; the programmer simply calls a cleanup method when exit.
* ```debug``` : provides ```assert()``` function, plus a bash stack and a unix stack trace dump functions

# Quick install

1. get ```pegasus-bash```:
```
mkdir $HOME/my/dir && cd $HOME/my/dir
git clone https://github.com/bzimage-it/pegasus-bash/
```
2. set ```PEGASUS_BASH_ROOT``` properly; you can do at beginning of your script:
```
#!/bin/bash
PEGASUS_BASH_ROOT=$HOME/my/dir/pegasus-bash
source $PEGASUS_BASH_ROOT/pegasus-bash.sh all
# ....my code follows....
```
note that setting of ```PEGASUS_BASH_ROOT``` is mandatory before to ```source(1)``` ```pegasus-bash```

3. you may want to ```export``` it in ```.bashrc```, or wherever you like:

```export PEGASUS_BASH_ROOT=$HOME/my/dir/pegasus-bash```

# Quick start

a [quickstart.sh](examples/quickstart.sh) script using ```pegasus-bash```:

```
$ cd examples
$ bash quickstart.sh foo=123 A=astring Directory= /tmp/
```

![Screenshot_2024-12-27_18-22-55](https://github.com/user-attachments/assets/ed54f033-3ebc-4b87-9ab8-4a83e2a70e06)

# Advanced and colored logging

see [log.sh example](examples/log.sh)

![Screenshot_2024-12-27_18-17-53](https://github.com/user-attachments/assets/a8e6a643-f39e-4ab1-acca-7d09248266f1)

# Quality and testing
target of this project is to have good testing and a good code review. This will be available in 1.0.0 release.

the script ```bash quality.sh``` helps to run static analysis (via [shellcheck](https://www.shellcheck.net/)) and dynamic/unit testing (via [bats-core](https://github.com/bats-core/bats-core); you needs both of them to test ```pegasus-bash``` but they are not needed to use the library.

Any recent linux distro shall works (but also not-too-much-older ones!)  It have been tested successfully on:
* ```bash 5.2.21`` on ```Ubuntu 24.04.1 LTS"
Let me know other test setup that is working or not. Thank you!

# To do

see [TODO](TODO.md) file
