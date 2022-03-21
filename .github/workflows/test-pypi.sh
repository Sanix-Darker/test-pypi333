#!/bin/bash

set -e

# install/upgrade pip
pip install -U pip

# assuming we identify a poetry project with the pyproject.toml
# at the root and setup.py as the default
TOM_FILE="$GITHUB_WORKSPACE/pyproject.toml"
SETUP_FILE="$GITHUB_WORKSPACE/setup.py"
LOG_FILE="$GITHUB_WORKSPACE/publish-output.log"

if [ -f "$TOM_FILE" ]; then

     echo "[-] $TOM_FILE exists, poetry install/build"

     # installation of poetry
     pip install -U poetry
     # configuration of the repository-url where the build will be pushed
     poetry config repositories.test-pypi https://test.pypi.org/legacy/
     poetry config pypi-token.pypi $TEST_PYPI_TOKEN
     # to update the version to an alpha one
     poetry version prerelease

     # We publish
     poetry publish --build > $LOG_FILE

     echo "::set-output name=publish-log::$(cat $LOG_FILE)\n"

elif [ -f "$SETUP_FILE" ]; then

     echo "[-] $SETUP_FILE exists, normal sdist/wheel build"

     pip install wheel twine

     # we generate a random version that will be pushed
     # VERSION=$(echo $RANDOM | md5sum | head -c 7;)
     # or the simple timestamp to be sure the next version
     # will be an int upper than the previous one
     sed -i 's/^.*version=.*$/version='$(date +%s)',/' $SETUP_FILE

     python $SETUP_FILE sdist bdist_wheel
     # we create our credential file for username, password and repository url
     cat <<EOF > ~/.pypirc
[distutils]
index-servers =
  testpypi

[testpypi]
username = __token__
password = $TEST_PYPI_TOKEN
repository = https://test.pypi.org/legacy/

EOF
     # the upload process
     twine upload -r testpypi dist/* > $LOG_FILE

     echo "::set-output name=publish-log::$(cat $LOG_FILE)\n"

else

     echo "[x] No $TOM_FILE nor $SETUP_FILE, will stop here !"
     ls -l

     exit 1

fi


