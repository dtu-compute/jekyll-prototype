#!/usr/bin/env ruby
require 'optparse'

MAX_LINE_LENGTH = 70

options = { output: '-' }
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby preprocess_enote_md.rb [OPTIONS] FILE'
  opts.on('-o', '--output FILE', 'Write output to FILE instead of stdout.') do |o|
    options[:output] = o
  end
end.parse!

unless (source_file = ARGV.shift)
  warn 'Please specify an Enote markdown source file to preprocess.'
  exit 1
end

IO.foreach(source_file) do |line|

  # Add extra line after comment line so pandoc will create a separation and not try to join
  # the two consecutive lines
  if line.start_with? '%'
    stripped_line = line[1..-1]
    line_length = 0
    words = []

    def output_words(words)
      puts '%' + words.join(' ') + "\n\n"
    end

    stripped_line.split(' ').each do |word|
      if (line_length + word.length + 1) < MAX_LINE_LENGTH
        words << word
        line_length += word.length + 1
      else
        output_words words
        words = []
        line_length = 0
      end
    end
    puts output_words(words) unless words.empty?

    puts "\n"
  else
    puts line.gsub('[Podcast link]', '[Podcastlink]')
  end
end
