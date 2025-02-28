#!/bin/bash

# Checking arg amount
if [ "$#" -ne 3 ]; then
  echo "This script must be used like this: $0 <number1> <number2> <number3>"
  exit 1
fi

# Finding min number
min=$1
if [ "$2" -lt "$min" ]; then
  min=$2
fi
if [ "$3" -lt "$min" ]; then
  min=$3
fi

echo "The minimum is $min"