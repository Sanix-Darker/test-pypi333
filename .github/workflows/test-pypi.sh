#!/bin/bash

set -e

# install/upgrade pip
pip install -U pip

# assuming we identify a poetry project with the pyproject.toml
# at the root and setup.py as the default
TOM_FILE="$GITHUB_WORKSPACE/pyproject.toml"
SETUP_FILE="$GITHUB_WORKSPACE/setup.py"
TMP_VERSION=$(date +%s)

if [ -f "$TOM_FILE" ]; then

     echo "[-] $TOM_FILE exists, poetry install/build"

     # installation of poetry
     pip install -U poetry
     # configuration of the repository-url where the build will be pushed
     poetry config repositories.test-pypi https://test.pypi.org/legacy/
     poetry config pypi-token.pypi $TEST_PYPI_TOKEN

     sed -i 's/^.*version.*=.*$/version = '$TMP_VERSION',/' $TOM_FILE

     # We publish
     poetry publish --build

elif [ -f "$SETUP_FILE" ]; then

     echo "[-] $SETUP_FILE exists, normal sdist/wheel build"

     pip install wheel twine

     sed -i 's/^.*version.*=.*$/version='$TMP_VERSION',/' $SETUP_FILE

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
     twine upload -r testpypi dist/*

else

     echo "[x] No $TOM_FILE nor $SETUP_FILE, will stop here !"
     exit 1

fi

REPOSITORY_NAME=$(echo "$GITHUB_REPOSITORY" | awk -F / '{print $2}')
echo "::set-output name=PKG::$(echo "$REPOSITORY_NAME==$TMP_VERSION")"
echo "::set-output name=MSG::$(echo "https://test.pypi.org/project/$REPOSITORY_NAME/$TMP_VERSION/")"

