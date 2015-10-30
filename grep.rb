#!/usr/bin/env ruby

require 'optparse'
require 'zip'
require 'pry'
require 'colorize'

class Args
  def initialize(args)
    @args = args
  end

  def parse_argv
    @conditions = { amount: 0, fnames: [] }
    OptionParser.new do |opts|
      opts.banner = 'Usage: [options] + PATTERN + [FILE]'
      opts.on('-A NLINES', Integer, 'Puts string with amount') do |amount|
        @conditions[:amount] = amount
      end
      opts.on('-f', '-files fn1,fn2,fn3', Array, 'Files for search') do |files|
        @conditions[:fnames] << files
      end
      opts.on('-R', 'Recursion in the current directory') do |_|
        @conditions[:fnames] << Dir.glob('*')
      end
      opts.on('-z znames', Array, 'In what zip file need to search') do |zname|
        @conditions[:zip] = znames
      end
    end.parse!(@args)
    # binding.pry
    @conditions[:pattern] = @args.shift
    @conditions[:fnames] << @args.shift if !@args.first.nil?
    validate_coditions
    @conditions
  end

  def validate_coditions
      binding.pry
      if @conditions[:pattern].nil? || (@conditions[:fnames].none? && @conditions[:zname].nil?)
      raise 'Wrong conditions format.'.red
    end
  end
end

class Grep
  def initialize(conditions)
    @conditions = conditions
  end

  def search_pattern
    unzip_file(@conditions[:zip]) if !@conditions[:zip].nil?
    find_content = []
    @conditions[:fnames].each do |fname|
      content = open_file(fname)
      scope = verification_pattern(content)
      # binding.pry
      find_content << { fname: fname, content: scope } if !scope.empty?
    end
    find_content
  end

  def verification_pattern(content, pattern = @conditions[:pattern])
    amount = @conditions[:amount]
    scope = []
    if !content.nil?
      content.each_with_index do |line, index|
        if line =~ /#{pattern}/
          scope << (content[index - amount..index + amount].join).green
        end
      end
    end
    scope
  end

  def open_file(fname)
    content = []
    File.open(fname).each { |line| content << line }
    content
  rescue
    puts "File: #{fname} cant be open.".red
  end

  def to_s
    find_content = ''
    search_pattern.each do |parse|
      find_content << (parse[:fname] + ":\n").blue
      parse[:content].each { |content| find_content << content }
    end
    find_content
  end

  def unzip_file
    Zip::File.open(@conditions[:zip]) do |zip_file|
      Dir.mkdir('tmp_dir') unless Dir.exist?('tmp_dir')
      zip_file.each do |files|
        zip_files.extract(files, "#{Dir.pwd}/tmp_dir") unless
        File.exist?('#{Dir.pwd}/tmp_dir')
        @conditions[:fnames] = Dir.glob('tmp_dir/*')
      end
      Dir.delete('./tmp_dir')
    end
  end
end

puts Grep.new(Args.new(ARGV).parse_argv).to_s
