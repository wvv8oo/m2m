#!/usr/bin/ruby -w
$VERBOSE = nil
require_relative './lib/generator'

Util.instance.workbench = Dir::pwd

Generator.new