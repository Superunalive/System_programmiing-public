#!/bin/bash

# Checking if argument is given (path)
if [ -z "$1" ]; then
  echo "This script must be used like this: $0 <catalog>"
  exit 1
fi

# Checking if it exists
if [ ! -d "$1" ]; then
  echo "Error: catalog '$1' does not exist."
  exit 1
fi

# Printing insides
echo "Catalog '$1' contains:"
ls -l "$1"