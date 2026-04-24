#!/bin/bash

NODE_VERSION=$(cat npm/node-version.txt)

nvm install "$NODE_VERSION"
nvm use "$NODE_VERSION"
