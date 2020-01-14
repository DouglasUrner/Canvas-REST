#!/usr/bin/env ruby

require 'rest-client'

def source(filename)
  # Inspired by user takeccho at http://stackoverflow.com/a/26381374/3849157
  # Sources sh-script or env file and imports resulting environment
  fail(ArgumentError,"File #{filename} invalid or doesn't exist.") \
     unless File.exist?(filename)

  _env_hash_str = `env -i sh -c 'set -a;source #{filename} && ruby -e "p ENV"'`
  fail(ArgumentError,"Failure to parse or process #{filename} environment")\
     unless _env_hash_str.match(/^\{("[^"]+"=>".*?",\s*)*("[^"]+"=>".*?")\}$/)

  _env_hash=eval(_env_hash_str)
   %w[ SHLVL PWD _ ].each{|k|_env_hash.delete(k) }
  _env_hash.each{|k,v| ENV[k]=v } # ENV does not have #merge!
end

source('private/ENV')

puts ENV['ACCESS_TOKEN']

#RestClient.get(url, headers={})
