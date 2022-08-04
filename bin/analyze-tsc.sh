#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  npx tsc --noEmit --listFiles | xargs stat -f "%z %N" | npx webtreemap-cli
else
  npx tsc --noEmit --listFiles | xargs stat -c "%s %n" | npx webtreemap-cli
fi
