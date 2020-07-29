#!/bin/bash

# this script reports the percentage space of par2 files relative to the
# other files.  I generally target about 1%, and this is a double-check on
# that.
ls -lR | awk '
  /par2$/ { p2tot = p2tot + $5; next } 
  NF >= 5 { tot = tot + $5 }
  END { print(p2tot/tot) }' 

