#!/bin/bash
set -e

/code/wait-for-it.sh -t 0 data-loader:80 -- echo "Data loader is up"
