#!/bin/bash
COUNT=$(ls *.sh | wc -l)
x=01
while [[ $x < $((COUNT+1)) ]]; do
  nano $x.sh
  x=$((x+1))
done
