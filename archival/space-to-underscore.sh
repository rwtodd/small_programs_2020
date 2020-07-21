#!/bin/bash

find . -type d -name '* *' | while read fn; do mv "${fn}" "${fn// /_}" ; done
find . -type f -name '* *' | while read fn; do mv "${fn}" "${fn// /_}" ; done

