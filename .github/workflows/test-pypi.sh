#!/bin/bash

set -e

# install/upgrade pip
pip install -U pip

# assuming we identify a poetry project with the pyproject.toml
# at the root and setup.py as the default
TOM_FILE="$GITHUB_REPOSITORY/pyproject.toml"
SETUP_FILE="$GITHUB_REPOSITORY/setup.py"

if [ -f "$TOM_FILE" ]; then

     echo "[-] $TOM_FILE exists, poetry install/build"

     # installation of poetry
     pip install -U poetry
     # configuration of the repository-url where the build will be pushed
     poetry config repositories.test-pypi https://test.pypi.org/legacy/
     poetry config pypi-token.pypi $TEST_PYPI_TOKEN
     # to update the version to an alpha one
     poetry version prerelease
     poetry publish --build

elif [ -f "$SETUP_FILE" ]; then

     echo "[-] $SETUP_FILE exists, normal sdist/wheel build"

     pip install wheel twine
     python setup.py sdist bdist_wheel
     # we create our credential file for username, password and repository url
     cat <<EOF > $HOME/.pypirc
[testpypi]
username = __token__
password = $TEST_PYPI_TOKEN
repository = https://test.pypi.org/legacy/

EOF
     # the upload process
     twine upload dist/*

else

     echo "[x] No $TOM_FILE nor $SETUP_FILE, will stop here !"
     exit 1

fi


