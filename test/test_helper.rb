ENV['RACK_ENV'] = 'test'
ENV['DATABASE_URL']='sqlite://db/test.sqlite3'

require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'])

require 'minitest/autorun'
require 'minitest/pride'

DB = Sequel.connect(ENV['DATABASE_URL'])

Dir[File.join(File.dirname(__FILE__), '../models', '*.rb')].each { |model| require model }
require File.expand_path('../../app', __FILE__)

require File.expand_path('../factories', __FILE__)

DatabaseCleaner.strategy = :transaction
DatabaseCleaner.clean_with(:truncation)

class Minitest::Test
  include FactoryBot::Syntax::Methods
end
