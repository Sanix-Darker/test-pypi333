import setuptools


VERSION = "0.0.1"

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="test-pypi",
    version=VERSION,
    author="Sanix-darker",
    author_email="s4nixd@gmail.com",
    description="Test Pypi",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/sanix-darker/test-pypi",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
)

