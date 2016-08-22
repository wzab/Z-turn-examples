#!/bin/ash
echo 905 > /sys/class/gpio/export ; echo high > /sys/class/gpio/gpio905/direction
