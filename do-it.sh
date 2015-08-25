#!/bin/bash

# This assumes that the mvcoffee git project is in a sibling directory
cd ../mvcoffee
cake minify

cd ../mvcoffee-rails
cp ../mvcoffee/lib/mvcoffee.* app/assets/javascripts/
gem build mvcoffee-rails.gemspec 
# gem install mvcoffee-rails
rake install:local