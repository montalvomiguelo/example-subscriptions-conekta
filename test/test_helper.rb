ENV['RACK_ENV'] = 'test'

require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'])

require 'minitest/autorun'
require 'minitest/pride'

require File.expand_path('../../app', __FILE__)
