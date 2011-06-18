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

  <h2>Applications</h2>
  <ul>
    <li><a href="http://userscripts.org/scripts/show/37064">usericonize favotter – Userscripts.org</a></li>
    <li><a href="http://statter.hoge.in/">すたったー / statter ::</a></li>
    <li><a href="http://twittstar.com/">TwittStar*</a></li>
    <li><a href="http://june29.jp/2008/11/03/show-twitter-user-icon-on-limechat/">LimeChatにTwitterのアイコンを表示させてみる - 準二級.jp</a></li>
    <li><a href="http://gellbates.com/">gellbates.com | Let's mimic other twitter-ers!</a></li>
    <li><a href="http://userscripts.org/scripts/show/36109">twitter faceiconize – Userscripts.org</a></li>
    <li><a href="http://userscripts.org/scripts/show/35359">LDR - twittericon – Userscripts.org</a></li>
  </ul>

  <h2>Source Code</h2>
  <p><a href="http://github.com/swdyh/usericons.relucks.org/tree/master">swdyh's usericons.relucks.org at master — GitHub</a></p>

  <h2>Donate Now</h2>
  <div><a href='http://www.pledgie.com/campaigns/2101'><img alt='Click here to lend your support to: usericons.relucks.org and make a donation at www.pledgie.com !' src='http://www.pledgie.com/campaigns/2101.png?skin_name=chrome' border='0' /></a></div>
</body>
</html>
