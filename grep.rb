#!/usr/bin/env ruby

class Grep 
  def initialize

  end

  def search(patern, file_names)
    file_names.each do |file|
      file_content = File.open(file){ |line| line.read.split("\n") }
      file_content.each { |line| puts line if line =~ /#{patern}/ }  
    end
  end
end

file_names = ["grep.rb", "Gemfile"] 
a = Grep.new
a.search("rails", file_names)