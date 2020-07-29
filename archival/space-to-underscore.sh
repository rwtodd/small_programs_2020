#!/bin/bash

# this script renames every file and directory it can find so that spaces
# are replaced by underscores.

find . -type d -name '* *' | while read fn; do mv "${fn}" "${fn// /_}" ; done
find . -type f -name '* *' | while read fn; do mv "${fn}" "${fn// /_}" ; done

