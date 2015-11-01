#!/usr/bin/env ruby

require 'optparse'
require 'pry'
require 'colorize'
require 'zlib'

class Args
  def initialize(args)
    @args = args
  end

  def parse_argv
    @conditions = { amount: 0 }
    OptionParser.new do |opts|
      opts.banner = 'Usage: PATTERN + FILE + [options]'
      opts.on('-A NLINES', Integer, 'Amount of context') do |amount|
        @conditions[:amount] = amount
      end
      opts.on('-f', '-files fn1,fn2,fn3', Array, 'Files for search') do |files|
        @conditions[:fnames] = files
      end
      opts.on('-R', 'Recursion in the current directory') do |_|
        @conditions[:fnames] = Dir.glob('*')
      end
      opts.on('-z zname', String, 'Gzip file for search') do |zname|
        @conditions[:zname] = zname
      end
    end.parse!(@args)
    @conditions[:pattern] = @args.shift
    @conditions[:fnames] << @args.shift unless @args.first.nil?
    validate_coditions
    @conditions
  end

  def validate_coditions
    if @conditions[:pattern].nil? ||
       (@conditions[:fnames].nil? && @conditions[:zname].nil?)
      fail 'Wrong conditions format.Use -h for help.'.red
    end
  end
end

class Grep
  def initialize(conditions)
    @conditions = conditions
  end

  def search_pattern
    @find_content = []
    unless @conditions[:zname].nil?
      content = unzname_file(@conditions[:zname])
      verification_pattern(content, @conditions[:zname])
    end
    unless @conditions[:fnames].nil?
      @conditions[:fnames].each do |fname|
        content = open_file(fname)
        verification_pattern(content, fname)
      end
    end
    @find_content
  end

  def verification_pattern(content, fname, pattern = @conditions[:pattern])
    amount = @conditions[:amount]
    scope = []
    unless content.nil?
      content.each_with_index do |line, index|
        if line =~ /#{pattern}/
          scope << (content[index - amount..index + amount].join).green
        end
      end
    end
    @find_content << { fname: fname, content: scope } unless scope.empty?
  rescue
    puts "File #{fname} have unreadable format\n".red
  end

  def open_file(fname)
    content = []
    File.open(fname).each { |line| content << line }
    content
  rescue
    puts "File: #{fname} cant be open.\n".red
  end

  def to_s
    search_pattern
    find_content = ''
    @find_content.each do |parse|
      find_content << (parse[:fname] + ":\n").blue
      parse[:content].each { |content| find_content << content }
    end
    find_content
  end

  def unzname_file(zname)
    content = []
    Zlib::GzipReader.open(zname).each { |line| content << line }
    content
  rescue
    puts "GZip file: #{zname} cant be open\n".red
  end
end

puts Grep.new(Args.new(ARGV).parse_argv).to_s
