#!/bin/bash

(ls -1t | head -1 | grep 'par2$') || \
    (rm -f *.par2 && par2 create -r1 -R __bkup .)

