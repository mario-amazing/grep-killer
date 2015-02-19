#!/usr/bin/env ruby

require 'optparse'
require 'zip'
require 'colorize'

class Grep 
  def initialize(options)
    search(options)
  end

  def search(options) 
    # if options[:zip] == true
    options[:fnames].each do |fname|
    File.open(fname).each { |line| puts "#{fname}:",line.colorize(:blue) if line =~ /#{options[:patern]}/ }  
    end
  end

  def unzip_file

  end
end

def parse_argv(args)
  options = {}
  options[:context] = 0
  options[:patern] = args[0]
  options[:fnames] = []
  options[:fnames] << args[1]
  OptionParser.new do |opts|
    opts.banner = "Usage: search string + function + [option]"
    # opts.on("-A NLINES","puts string with context") do |amount|
      # options[:context] = amount
    # end
    opts.on("-f","-files fn1,fn2,fn3","In what files need search") do |files|
      options[:fnames] = files.split(",")
    end
    opts.on("-R","Recursion in the current directory") do |_|
      options[:fnames] = Dir.glob("*")
    end
    # opts.on("-z fname","In what zip file need to search") do |zname|
    #   Zip::File.open(zname) do |zip_file| ##{Dir.pwd}/#{zname}
    #     Dir.mkdir("")
    #     zip_file.each do |entry|
    #     puts "Extracting #{entry.name}"
    #     entry.extract(dest_file)
    #     end
      # end
    # end
    opts.on("-h","--help","Options info") do
      puts opts
      exit
    end
  end.parse!(args)
  options
end   

options = parse_argv(ARGV)
a = Grep.new(options)
# puts ARGV
# puts options
