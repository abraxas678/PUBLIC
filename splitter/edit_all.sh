#!/bin/bash
ls >myfiles
  while IFS= read -r line; do
     nano $line
  done < myfiles
rm -f myfiles
