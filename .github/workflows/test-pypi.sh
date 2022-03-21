#!/bin/bash

set -e

# install/upgrade pip
pip install -U pip

# assuming we identify a poetry project with the pyproject.toml
# at the root and setup.py as the default
TOM_FILE="$GITHUB_WORKSPACE/pyproject.toml"
SETUP_FILE="$GITHUB_WORKSPACE/setup.py"
TMP_VERSION=$(date +%s)
REPOSITORY_NAME=$(echo "$GITHUB_REPOSITORY" | awk -F / '{print $2}')

if [ -f "$TOM_FILE" ]; then

     echo "[-] $TOM_FILE exists, poetry install/build"

     # installation of poetry
     pip install -U poetry

     sed -i 's/^.*version.*=.*$/version = '\"$TMP_VERSION\"'/' $TOM_FILE
     # the build process
     poetry build
elif [ -f "$SETUP_FILE" ]; then

     echo "[-] $SETUP_FILE exists, normal sdist/wheel build"

     pip install wheel

     sed -i 's/^.*version.*=.*$/version='$TMP_VERSION',/' $SETUP_FILE
     # The build process
     python $SETUP_FILE sdist bdist_wheel
else

     echo "[x] No $TOM_FILE nor $SETUP_FILE, will stop here !"
     exit 1

fi

# The upload/publish process
pip install twine

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
twine upload -r testpypi "$GITHUB_WORKSPACE/dist/*"

# we set output vars for next steps
echo "::set-output name=PKG::$(echo "$REPOSITORY_NAME==$TMP_VERSION")"
echo "::set-output name=MSG::$(echo "https://test.pypi.org/project/$REPOSITORY_NAME/$TMP_VERSION/")"

