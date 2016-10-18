#!/bin/ash
modprobe axi4s2dmov
echo 904 > /sys/class/gpio/export
echo low > /sys/class/gpio/gpio904/direction
echo high > /sys/class/gpio/gpio904/direction
echo 905 > /sys/class/gpio/export
echo low > /sys/class/gpio/gpio905/direction
echo high > /sys/class/gpio/gpio905/direction

