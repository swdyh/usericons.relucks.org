#!/usr/bin/env ruby

require 'open-uri'
require 'rubygems'
require 'json'

URL = 'http://wedata.net/databases/usericons/items.json'
CACHE_DIR = 'tmp'

si = JSON.parse(open(URL).read).map { |i| i['data'] }
path = File.join(File.dirname(__FILE__), CACHE_DIR, 'siteinfo.json')
open(path, 'w') do |f|
  f.puts JSON.pretty_generate(si)
  puts "[update.rb] #{Time.now.strftime('%Y/%m/%d-%H:%M:%S')} update #{path}"
end

