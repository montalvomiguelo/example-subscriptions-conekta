require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'])

Dotenv.load

require 'logger'

DB = Sequel.connect(ENV['DATABASE_URL'], logger: Logger.new($stdout))

Conekta.api_key = ENV['PRIVATE_KEY']
Conekta.api_version = '2.0.0'

Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each { |model| require model }
require './app'

run App
