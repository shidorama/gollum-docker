#!/bin/bash
source /etc/environment
export $(cut -d= -f1 /etc/environment)
make -C /wiki/tmp