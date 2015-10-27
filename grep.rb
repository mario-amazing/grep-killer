#!/usr/bin/env ruby

require 'optparse'
require 'zip'
require 'pry'

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
    @conditions[:pattern] = @args.shift
    @conditions[:fnames] << @args.shift
    @conditions
  end
end

class Grep
  def initialize(conditions)
    @conditions = conditions
  end

  def search_pattern
    unzip_file(@conditions[:zip]) if !@conditions[:zip].nil?
    amount = @conditions[:amount]
    find_content = []
    @conditions[:fnames].each do |fname|
      file_content = open_file(fname)
      scope = []
      file_content.each_with_index do |line, index|
        if line =~ /#{@conditions[:pattern]}/
          scope << file_content[index - amount..index + amount].join
        end
      end
      find_content << { fname: fname, content: scope }
    end
    find_content
  end

  def open_file(fname)
    content = []
    File.open(fname).each { |line| content << line }
    content
  rescue
    puts "File: #{fname} cant be open."
  end

  def to_s
    find_content = ''
    search_pattern.each do |parse|
      find_content << parse[:fname] + ":\n"
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
