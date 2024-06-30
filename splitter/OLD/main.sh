#!/bin/bash
cp index.txt tmp.csv
sed -i 's/. /;/'
rich --csv tmp.csv
