#!/bin/bash
set -e
rm -f /tmp/rdpipe /tmp/wrpipe
# Create the named pipes
mknod /tmp/rdpipe p
mknod /tmp/wrpipe p
# Run the python script in the other xterm
xterm -e "python -i ipbus_test.py; echo 'press ENTER'; read" &
