#!/bin/bash

ls -l | awk '
  /par2$/ { p2tot = p2tot + $5; next } 
  { tot = tot + $5 }
  END { print(p2tot/tot) }' 

