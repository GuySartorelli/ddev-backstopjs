setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-addon-backstopjs
  mkdir -p $TESTDIR
  export PROJNAME=test-addon-backstopjs
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}


  ddev start -y >/dev/null
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

check_installed () {
  # backstop is installed and can show its version
  echo "Checking backstopjs version with `ddev backstopjs local version`" >&3
  ddev backstopjs local version | grep 'Command "version" successfully executed' >&3
}

check_backstopjs () {
  # Create reference bitmaps
  echo "Creating backstopjs references with `ddev backstopjs local reference`" >&3
  ddev backstopjs local reference >&3
  # Test should pass because there is a reference bitmaps
  echo "Testing backstopjs references with `ddev backstopjs local test`" >&3
  ddev backstopjs local test >&3
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  echo "Installed add-on from directory, restarting ddev" >&3
  ddev restart

  echo "Testing backstopjs" >&3
  check_installed
  check_backstopjs
}




#@test "install from release" {
#  set -eu -o pipefail
#  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
#  echo "# ddev get drud/ddev-addon-template with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
#  ddev get drud/ddev-addon-template
#  ddev restart >/dev/null
#  # Do something useful here that verifies the add-on
#  # ddev exec "curl -s elasticsearch:9200" | grep "${PROJNAME}-elasticsearch"
#}
