#!/usr/bin/env ruby
# Copyright (c) 2017 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

STDOUT.sync = true

require 'net/http'
require 'date'
require 'nokogiri'
require 'slop'

def get(path)
  uri = URI.parse("http://repo1.maven.org/maven2/#{path}")
  req = Net::HTTP::Get.new(uri.to_s)
  res = Net::HTTP.start(uri.host, uri.port) do |http|
    http.request(req)
  end
  res.body
end

def scrape(path, ignore = [], start = '')
  body = get(path)
  if (body.include?('maven-metadata.xml'))
    match = body.match(%r{maven-metadata.xml</a>\s+(\d{4}-\d{2}-\d{2} )})
    date = Date.strptime(match[1], '%Y-%m-%d')
    meta = Nokogiri::XML(get("#{path}maven-metadata.xml"))
    version = meta.xpath('//versions/version[last()]/text()')
    puts "#{path} #{version} #{date}"
  else
    found = false
    body.scan(%r{href="([a-zA-Z\-]+/)"}).each do |p|
      target = "#{path}#{p[0]}"
      found = true if target.start_with?(start)
      unless found
        puts "SKIP #{target}, STILL LOOKING FOR #{start}"
        next
      end
      unless ignore.select{ |i| target.start_with?(i) }.empty?
        puts "EXCLUDE #{target}"
        next
      end
      scrape(target, ignore)
    end
  end
end

begin
  opts = Slop.parse(ARGV, strict: true, help: true) do |o|
    o.banner = "Usage: ruby scrabe.rb [options]"
    o.bool '-h', '--help', 'Show these instructions'
    o.string '-r', '--root', 'Root path to start from', default: ''
    o.array '-i', '--ignore', 'Prefixes to ignore, like "org/", for example'
    o.string '-s', '--start', 'Start from this path', default: ''
  end
rescue Slop::Error => ex
  raise StandardError, "#{ex.message}, try --help"
end

if opts.help?
  puts opts
  exit
end

scrape(opts[:root], opts[:ignore], opts[:start])

