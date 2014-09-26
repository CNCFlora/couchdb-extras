#!/usr/bin/env bash

if [[ ! -e ~/.app_done ]]; then
    add-apt-repository ppa:brightbox/ruby-ng -y
    apt-get update
    apt-get upgrade -y
    apt-get install aptitude wget curl ruby2.1 -y
    gem install rspec
    touch ~/.app_done
fi

