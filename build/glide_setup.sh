#!/bin/bash

# This script installs glide binary, to be used for go version below 1.5
if [ ! -f "glide" ]; then
    go_version=`go version`
    glide_version="v0.12.3"
    glide_url="http://github.com/Masterminds/glide/releases/download/$glide_version"
    glide_os=""
    if [[ $go_version == *"linux/amd64"* ]]; then
      glide_os="linux-amd64"
    elif [[ $go_version == *"darwin/amd64"* ]]; then
      glide_os="darwin-amd64"
    elif [[ $go_version == *"linux/386"* ]]; then
      glide_os="linux-386"
    elif [[ $go_version == *"darwin/386"* ]]; then
      glide_os="darwin-386"
    fi

    glide_file="glide-$glide_version-$glide_os.tar.gz"
    if [ ! -d "glide" ]; then
       if [ -x wget ]; then
          wget -q "$glide_url/$glide_file"
       else
          curl -s -O -L "$glide_url/$glide_file"
       fi
       tar -zxf "$glide_file"
    fi
    mv "$glide_os/glide" .
    rm -rf $glide_os
    rm -f "$glide_file"
fi
