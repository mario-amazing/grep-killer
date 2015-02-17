#!/usr/bin/env ruby

require 'optparse'
USAGE = "Usage: search string + function + [option]"

class Grep 
  def initialize

  end

  def search(options) 
    options[:fnames].each do |file|
    File.open(file).each { |line| puts line if line =~ /#{options[:patern]}/ }  
    end
  end
end

def parse_argv(args)
  options = {}
  options[:context] = 0
  options[:patern] = args[0]
  options[:fnames] = args[1].split(",")
  OptionParser.new do |opts|
    opts.banner = USAGE
    opts.on("-A","puts string with context") do
      options[:context] = 1
    end
    opts.on("-h","--help","Options info") do
      puts opts
      exit
    end
  end.parse!(args)
  options
end   

#file_names = ["grep.rb", "Gemfile"] 
options = parse_argv(ARGV)
a = Grep.new
a.search(options)

#puts ARGV
#a.search("rails", file_names, "-h")
