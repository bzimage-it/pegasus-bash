#!/usr/bin/env bats

PEGASO_BASH_IMPORT_VERBOSE=1
export PEGASO_BASH_ROOT="$(readlink -f .)"

test ! -d test && echo "bats test suite shall be executed from main directory; a 'test' directory was expected here" && exit 1

tmp=

mktmplink() {
      oldpwd="$PWD"
      tmp="$(mktemp -d)"
      mkdir -p $tmp/1/2/3
      cp -v test/location-minimal.sh $tmp/testme
      cd $tmp/1/2/3
      pwd
      ln -sv ../../../testme testme3      
      ls -l
      cd ..
      ln -sv ../../testme testme2
      cd "$oldpwd"
}

@test "basic location identification" {
  cd ..
  f="${BASH_SOURCE[0]}"
  d="$(dirname "$f")"
  b="$(basename "$f")"
  echo $p
  source "$PEGASO_BASH_ROOT"/pegaso-bash.sh location || exit 3
  [ "$PEGASO_SCRIPT_FULL" == "$f" ]
  [ "$PEGASO_SCRIPT_DIR"  == "$d" ]
  [ "$PEGASO_SCRIPT_FILE"  == "$b" ]	
}

@test "with symlink level 0" {
      mktmplink
      [ "$(bash $tmp/testme PEGASO_SCRIPT_FULL)" == "$tmp/testme" ]
      [ "$(bash $tmp/testme PEGASO_SCRIPT_DIR)" == "$tmp" ]
      [ "$(bash $tmp/testme PEGASO_SCRIPT_FILE)" == "testme" ]
      rm -rfv $tmp
}

@test "with symlink level 3 outside" {
      mktmplink
      [ "$(bash $tmp/1/2/3/testme3 PEGASO_SCRIPT_FULL)" == "$tmp/testme" ]
      [ "$(bash $tmp/1/2/3/testme3 PEGASO_SCRIPT_DIR)" == "$tmp" ]
      [ "$(bash $tmp/1/2/3/testme3 PEGASO_SCRIPT_FILE)" == "testme" ]
      rm -rfv $tmp
}

@test "with symlink level 3 inside" {
      mktmplink
      cd $tmp/1/2/3
      [ "$(bash testme3 PEGASO_SCRIPT_FULL)" == "$tmp/testme" ]
      [ "$(bash testme3 PEGASO_SCRIPT_DIR)" == "$tmp" ]
      [ "$(bash testme3 PEGASO_SCRIPT_FILE)" == "testme" ]     
      rm -rfv $tmp
}      

@test "with symlink level 2 outside" {
      mktmplink
      [ "$(bash $tmp/1/2/testme2 PEGASO_SCRIPT_FULL)" == "$tmp/testme" ]
      [ "$(bash $tmp/1/2/testme2 PEGASO_SCRIPT_DIR)" == "$tmp" ]
      [ "$(bash $tmp/1/2/testme2 PEGASO_SCRIPT_FILE)" == "testme" ]
      rm -rfv $tmp      
}

@test "with symlink level 2 inside" {
      mktmplink
      cd $tmp/1/2
      [ "$(bash testme2 PEGASO_SCRIPT_FULL)" == "$tmp/testme" ]
      [ "$(bash testme2 PEGASO_SCRIPT_DIR)" == "$tmp" ]
      [ "$(bash testme2 PEGASO_SCRIPT_FILE)" == "testme" ]
      rm -rfv $tmp      
}








