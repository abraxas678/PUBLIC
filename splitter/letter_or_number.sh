#!/bin/bash

# Example variable
ANS="$@"

# Function to check if a string contains only letters
is_letter() {
    [[ $1 =~ ^[[:alpha:]]$ ]]
}

# Function to check if a string contains only numbers
is_number() {
    [[ $1 =~ ^[[:digit:]]+$ ]]
}

# Check if $ANS is a letter
if is_letter "$ANS"; then
    echo "letter."
elif is_number "$ANS"; then
    echo "number."
else
    echo "$ANS is neither a letter nor a number."
fi

