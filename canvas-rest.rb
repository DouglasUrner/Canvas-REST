#!/usr/bin/env ruby

require 'json'
require 'rest-client'

def source(filename)
  # Inspired by user takeccho at http://stackoverflow.com/a/26381374/3849157
  # Sources sh-script or env file and imports resulting environment
  fail(ArgumentError, "File #{filename} invalid or doesn't exist.") \
     unless File.exist?(filename)

  _env_hash_str = `env -i sh -c 'set -a;source #{filename} && ruby -e "p ENV"'`
  fail(ArgumentError,"Failure to parse or process #{filename} environment") \
     unless _env_hash_str.match(/^\{("[^"]+"=>".*?",\s*)*("[^"]+"=>".*?")\}$/)

  _env_hash = eval(_env_hash_str)
   %w[ SHLVL PWD _ ].each{ |k| _env_hash.delete(k) }
  _env_hash.each{ |k,v| ENV[k] = v }
end

source('private/ENV')

@base = 'https://canvas.instructure.com/api'
path = '/v1/courses/1692944/sections'
course_id = '1692944'

def headers
  {
    Authorization: "Bearer #{ENV['ACCESS_TOKEN']}"
  }
end

def sections(course_id)
  route = "/v1/courses/#{course_id}/sections"

  response = RestClient.get(@base + route, headers)
  sections = JSON.parse(response)

  sections.each do |s|
    puts "#{s['name']}: #{s['id']}"
  end
end

sections(course_id)
