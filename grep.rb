#!/usr/bin/env ruby

require 'optparse'
require 'zip'
require 'colorize'

class Grep 
  def initialize(options)
    @options = options
  end

  def search(patern = @options[:patern],fnames =  @options[:fnames])
    if @options[:zip] != false
      fnames = unzip_file(@options[:zip])
      search_in_files(patern, fnames)
      Dir.delete("./tmp_dir" )
    else
      search_in_files(patern, fnames)
    end
  end

  def search_in_files(patern, fnames)
    fnames.each do |fname|
      content = []
      lines_array = []
      File.open(fname).each { |line| content << line}
      content.each_with_index { |line,index| lines_array << index if line =~ /#{patern}/ }
      display(fname, content, lines_array)
    end
  end

  def unzip_file(zname)
    Zip::File.open(zname) do |zip_file|
      Dir.mkdir("tmp_dir") unless Dir.exist?("tmp_dir")          
      zip_file.each do |files|
      zip_files.extract(files, "#{Dir.pwd}/tmp_dir") unless File.exist?("#{Dir.pwd}/tmp_dir")
      @options[:fnames] = Dir.glob("tmp_dir/*")
      # puts options[:fnames]
      end
    end
    @options[:fnames]
  end

  def display(fname, content, lines_array)
    arg = @options[:context]
    puts "#{fname}:".colorize(:green)
    lines_array.each {|index| puts content[index-arg .. index+arg]} 
    puts ''
  end
end

def parse_argv(args)
  options = {}
  options[:context] = 0
  options[:zip] = false
  options[:patern] = args.first
  options[:fnames] = []
  options[:fnames] << args[1]
  OptionParser.new do |opts|
    opts.banner = "Usage: search string + function + [option]"
    opts.on("-A NLINES", OptionParser::OctalInteger, "puts string with context") do |amount|
      options[:context] = amount
    end
    opts.on("-f", "-files fn1,fn2,fn3", Array, "In what files need search") do |files|
      options[:fnames] = files
    end
    opts.on("-R", "Recursion in the current directory") do |_|
      options[:fnames] = Dir.glob("**")
    end
    opts.on("-z fname", "In what zip file need to search") do |zname|
      options[:zip] = zname
    end
  end.parse!(args)
  options
end   

options = parse_argv(ARGV)
a = Grep.new(options)
a.search()
# puts ARGV
# puts options
