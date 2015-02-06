#!/usr/bin/env ruby

class Grep 
  def initialize(str = "class", file_name = File.dirname(__FILE__) + "/grep.rb")
    @str = str
    @file_name = File.dirname(__FILE__) + "#{file_name}"
  end

  def search
    file_content = File.open(@file_name){ |file| file.read.split("\n") }
    file_content.each { |line| puts line if line.include? "#{@str}" }  
  end
end

a = Grep.new("adfasdf","/grep.rb")
a.search