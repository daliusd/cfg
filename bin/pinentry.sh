#!/bin/sh

if [[ "$OSTYPE" == "linux"* ]]; then
  /usr/bin/pinentry
else
  /usr/local/bin/pinentry-mac
fi
