require 'rake/testtask'

namespace :test do
  task :prepare do
    `sequel -m db/migrate sqlite://db/test.sqlite3`
  end
end

task :test do
  Rake::TestTask.new do |t|
    t.pattern = 'test/*_test.rb'
    t.libs << 'test'
    t.verbose = true
  end
end
