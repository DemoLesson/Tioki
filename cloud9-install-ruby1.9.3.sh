#!/bin/bash

# This script downloads and installs Ruby 1.9.3-p194 into Cloud9 workspace.
# It makes possible to use Ruby 1.9 for running apps there instead of default Ruby 1.8.7

# Create this file in a root of your workspace.
# Run in command line: chmod +x install-cloud9.sh
# And: ./install-cloud9.sh
# It will take some time to download and compile libyaml and ruby.
# Adjust ruby version paths according to your needs.

# Output usually triples.
# A lot of locale related errors, but they seem not to make anything wrong.

set -e

mkdir installs
cd installs

export LD_LIBRARY_PATH=$HOME/lib:$LD_LIBRARY_PATH
export INCLUDE=$HOME/include:$INCLUDE


echo "Downloading libyaml and ruby".

curl -OsS http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
curl -OsS http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz

tar xzf yaml-0.1.4.tar.gz
cd yaml-0.1.4
echo "Configuring libyaml. Will show last 10 lines of outputs only. And all the errors and warnings."
./configure --prefix=$HOME | tail
echo "Compiling libyaml."
make install | tail


cd ..
tar xzf ruby-1.9.3-p194.tar.gz
cd ruby-1.9.3-p194

echo "Configuring ruby."
./configure --prefix=$HOME --with-opt-dir=$HOME | tail

echo "Compiling ruby."
make install | tail

echo "Checking versions:"
ruby -v
gem -v

echo "The above commands must show appropriate versions of ruby and gem".
echo "If everything looks fine you should run:"
echo "rm -rf installs" 
echo "gem install bundler"

#yay!