#!/usr/bin/env ruby -rubygems

# Redistribution and use in source and binary forms, with or without modification, are permitted provided
# that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this list of conditions and the
# following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
# the following disclaimer in the documentation and/or other materials provided with the distribution.
#
# Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or
# promote products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'sinatra'
require 'sass'
require 'erb'
require 'haml'
require 'logger'

api_version = '1'

logger = Logger.new(STDOUT)

configure do
  enable :logging
end


## Pusher.com settings (private)
Pusher.app_id = ENV['PUSHER_APP_ID']
Pusher.key = ENV['PUSHER_KEY']
Pusher.secret = ENV['PUSHER_SECRET']

if !Pusher.app_id
  raise StandardError, "Pusher app_id is not defined. Please set env variables PUSHER_APP_ID, PUSHER_KEY, and PUSHER_SECRET"
end

## Memcached client:
set :cache, Dalli::Client.new

# Quick test
get '/' do
  @ac_power = settings.cache.get(:ac_power)
  @measured_temp = settings.cache.get(:measured_temp)
  @desired_temp = settings.cache.get(:desired_temp)
  @fan_speed = settings.cache.get(:fan_speed)
  haml :index
end

get '/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss :stylesheet
end

post '/queue' do
  vals = { :ac_power     => params[:ac_power],
           :desired_temp => params[:desired_temp],
           :fan_speed    => params[:fan_speed]}
  
  logger.info "Changing A/C settings:"
  logger.info " ac_power = #{vals[:ac_power]}"
  logger.info " desired_temp = #{vals[:desired_temp]}"
  logger.info " fan_speed = #{vals[:fan_speed]}"
  begin
    # channel is 'cloudcomfort', event is 'ac'
    Pusher['cloudcomfort'].trigger!('ac', build_arduino_response(vals))
  rescue Pusher::Error => e
    # (Pusher::AuthenticationError, Pusher::HTTPError, or Pusher::Error)
    # TODO: report this back to the browser/AJAX response.
    logger.error e
    status 500 and return
  end
  
  # save desired values if Pusher was successful
  # TODO : Arduino should force a HTTP POST when receiving the Pusher notice? to confirm receipt?
  settings.cache.set(:ac_power, vals[:ac_power])
  settings.cache.set(:desired_temp, vals[:desired_temp])
  settings.cache.set(:fan_speed, vals[:fan_speed])

  status 200 
end


## API Methods

# From the Arduino:
post '/api/'+ api_version + '/poll' do
  request.body.rewind
  b = request.body.read
  logger.info "Request body: #{b}"
  # Temperature, celcius (number)
  temp = params[:tempc].to_i
  logger.info "Receiving temperature report: '#{temp}'"

  settings.cache.set('measured_temp', temp)
  request.body.rewind # in case someone already read it
  status 200
end

def build_arduino_response(vals)
  response = "ac=#{vals[:ac_power]}\r\ntempc=#{vals[:desired_temp]}\r\nfan=#{vals[:fan_speed]}\r\n"
  logger.info "Arduino response: '#{response}'"
  return response
end

# Test at <appname>.heroku.com

# You can see all your app specific information this way.
# IMPORTANT! This is a very bad thing to do for a production
# application with sensitive information

# get '/env' do
# ENV.inspect
# end
