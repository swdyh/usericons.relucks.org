# -*- coding: utf-8 -*-

require 'fileutils'
require 'erb'
require 'rubygems'
require 'sinatra'
require 'avaticon'

include ERB::Util

def encode64url arg
  [arg].pack('m').tr('+/', '-_').strip
end

CACHE_DIR = 'tmp/icons'
CACHE_EXPIRE = 60 * 60 * 24
HTTP_CACHE_EXPIRE = 60 * 60 * 24

unless File.exists?(CACHE_DIR)
  FileUtils.mkdir_p CACHE_DIR
end

get '/' do
  base_url = [request.scheme,  '://', request.host, request.port == 80 ? '' : ':' + request.port.to_s, '/'].join('')
  avt = Avaticon.new
  avt.load_siteinfo File.join('tmp', 'siteinfo.json')
  if params.key? 'url'
    begin
      url = params['url']
      path = File.join(CACHE_DIR, encode64url(url))
      if File.exist?(path) && File.mtime(path) > (Time.now - CACHE_EXPIRE)
        redirect IO.read(path).strip
      end
      icon_url = avt.search_by_url url
      open(path, 'w') { |f| f.puts icon_url }
      redirect icon_url
    rescue Exception => e
      throw :halt, [500, 'server error.']
    end
  else
    erb :index, :locals => { :avt => avt, :base_url => base_url }
  end
end

get '/:service/:user_id' do
  avt = Avaticon.new
  avt.load_siteinfo File.join('tmp', 'siteinfo.json')

  service = params[:service]
  user_id = params[:user_id]

  if !service || !user_id || !avt.services.include?(service)
    throw :halt, [501, 'not availavle service.']
  end

  path = File.join(CACHE_DIR, encode64url("#{service}_#{user_id}"))
  if File.exist?(path) && File.mtime(path) > (Time.now - CACHE_EXPIRE)
    set_cache
    redirect IO.read(path).strip
  end

  begin
    icon_url = avt.get_icon service, user_id
    raise 'error' unless icon_url
    open(path, 'w') { |f| f.puts icon_url }
    set_cache
    redirect icon_url
  rescue Exception => e
    throw :halt, [500, 'server error.']
  end
end

def set_cache
  headers 'Cache-Control' => "private, max-age=#{HTTP_CACHE_EXPIRE}"
end

# use_in_file_templates!

__END__

@@ index
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja" xml:lang="ja">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>usericons.relucks.org</title>
  <link href="usericons.css" media="screen" rel="stylesheet" type="text/css" />
</head>
<body>
  <h1>UserIcons</h1>
  <h2>API</h2>
  <div><%=h base_url %>{service}/{user_id}</div>
  <div><%=h base_url %>?url={url}</div>

  <h2>Examples</h2>
  <div><%=h base_url %>twitter/swdyh</div>
  <div><%=h base_url %>?url=http://twitter.com/swdyh</div>

  <h2>Available Services</h2>
  <dl>
  <% avt.siteinfo.sort_by{|i| i['service_name'] }.each do |i| %>
    <dt class="service_name"><%=h i['service_name'] %></dt>
    <dd class="service_url"><%=h base_url %><%=h i['service_name'] %>/{user_id}</dd>
  <% end %>
  </dl>

  <div class="powered">
    powered by <a href="http://www.dotcloud.com">www.dotcloud.com</a>
  </div>
</body>
</html>
