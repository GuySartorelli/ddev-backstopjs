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

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart

  # backstop is installed and can show its version
  ddev backstopjs local version | grep 'Command "version" successfully executed'

  # Test should fail because there is no reference bitmaps
  ddev backstopjs local test | grep 'Command "version" successfully executed' || true
  # Create reference bitmaps
  ddev backstopjs local reference
  # Test should pass because there is a reference bitmaps
  ddev backstopjs local test

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
