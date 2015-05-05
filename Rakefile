require './app.rb'
require 'sinatra/activerecord/rake'
require 'rake/testtask'

describe "Run all tests"
Rake::TestTask.new(name =:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
end
