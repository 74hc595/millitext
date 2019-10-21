#!/usr/bin/env ruby

ENV['GEM_HOME'] = '/home/protected/gems'
ENV['GEM_PATH'] = '/home/protected/gems:/usr/local/lib/ruby/gems/2.3'

require 'cgi'
require 'base64'
require_relative 'milligen'

BRV = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-"

def decode_text(str)
  [[/\./,'+'], [/-/,'/'], [/_/,'=']].each {|m| str.gsub!(*m)}
  return Base64.decode64(str)
end

def decode_options(options)
  ret = [1, false, false, false]
  ret[0] = 2 if (options & 1) > 0
  ret[1] = (options & 2) > 0
  ret[2] = (options & 4) > 0
  ret[3] = (options & 8) > 0
  return ret
end

def decode_brightness(br)
  val = BRV.index(br)
  if val == nil
    return 63
  else
    return val
  end
end

### main
cgi = CGI.new

if !cgi.params.include? 't' then
  puts cgi.header('text/plain')
  puts "I'd like some text, please."
  exit
end

textraw = cgi.params['t']
text = decode_text(textraw[0])
text = text.slice(0,1000)
text.upcase!

options = cgi.params['o']
if options.empty? then
  options = 0
else
  options = options[0].to_i(16)
end

font, center, invert, transp = decode_options(options)

bright = cgi.params['b']
if bright.empty? then
  bright = 63
else
  bright = decode_brightness(bright[0])
end

bright = 63 if bright < 0 || bright > 63
bright = bright.to_f / 63.0

# generate and output the image
output = millitext(text, font, center, invert, transp, bright)
if !output then
  puts cgi.header('text/plain')
  puts "You're doing it wrong."
  exit
end

output.format = "PNG"
output.set_channel_depth(AllChannels,8);
puts cgi.header('image/png')
output.write($stdout)
