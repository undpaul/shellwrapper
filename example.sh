#!/bin/bash

# Normalize by relocating to the current scripts folder.
cd "$(dirname ${0})"

# This is the simple call that uses the shellwrapper to process all scripts
# in the example folder.
bash shellwrapper.sh ./example local,post,notify
