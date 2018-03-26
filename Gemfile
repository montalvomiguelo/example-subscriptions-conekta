source 'https://rubygems.org'


gem 'sinatra'
gem 'sequel'
gem 'puma'
gem 'attr_encrypted'
gem 'conekta'
gem 'mocha'
gem 'sinatra-contrib'

group :production do
  gem 'mysql2'
end

group :development, :test do
  gem 'pry-byebug'
  gem 'sqlite3'
end

group :development do
  gem 'rake'
  gem 'dotenv'
end

group :test do
  gem 'rack-test'
  gem 'minitest'
  gem 'factory_bot'
  gem 'database_cleaner'
end
