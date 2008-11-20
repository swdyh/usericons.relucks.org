require 'rubygems'
require 'rake/clean'
require 'fileutils'

task :default => :test

desc 'Run specs with story style output'
task :spec do
  sh 'specrb --specdox -Ilib:test test/*_test.rb'
end

desc 'Run specs with unit test style output'
task :test => FileList['test/*_test.rb'] do |t|
  suite = t.prerequisites.map{|f| "-r#{f.chomp('.rb')}"}.join(' ')
  sh "ruby -Ilib:test #{suite} -e ''", :verbose => false
end

desc 'update siteinfo.json'
task :update_siteinfo do
  load 'update.rb'
end

CLEAN.include 'tmp/*'

