#!/bin/bash

# Checking arguments
if [ -z "$1" ]; then
  echo "This script must be used like this: $0 <имя_файла>"
  exit 1
fi

# Saving the list in file
ps -ef > "$1"

echo "List of processes is saved here: '$1'."