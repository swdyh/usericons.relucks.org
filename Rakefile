require 'rubygems'
require 'rake/clean'
require 'fileutils'

REMOTE_HOST = 'relucks.org'

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

namespace :remote do
  desc 'update usericons.relucks.org'
  task :update do
    sh "ssh #{REMOTE_HOST} 'cd www/usericons.relucks.org/ && git pull && sudo /etc/init.d/apache2 restart'"
  end

  desc 'passenger-memory-stats'
  task :pmem do
    sh "ssh #{REMOTE_HOST} passenger-memory-stats"
  end

  desc 'free -m'
  task :free do
    sh "ssh #{REMOTE_HOST} free -m"
  end
end

CLEAN.include 'tmp/*'

