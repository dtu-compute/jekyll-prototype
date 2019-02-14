#!/usr/bin/env ruby

# FROM https://github.com/asciidoctor/asciidoctor-extensions-lab/blob/master/scripts/asciidoc-coalescer.rb

# This script coalesces the AsciiDoc content from a document master into a
# single output file. It does so by resolving all preprocessor directives in
# the document, and in any files which are included. The resolving of include
# directives is likely of most interest to users of this script.
#
# This script works by using Asciidoctor's PreprocessorReader to read and
# resolve all the lines in the specified input file. The script then writes the
# result to the output.
#
# The script only recognizes attributes passed in as options or those defined
# in the document header. It does not currently process attributes defined in
# other, arbitrary locations within the document.

# TODO
# - add cli option to write attributes passed to cli to header of document
# - escape all preprocessor directives after lines are processed (these are preprocessor directives that were escaped in the input)
# - wrap in a custom converter so it can be used as an extension

require 'asciidoctor'
require 'optparse'
require 'pry'


class TextConverter
  include Asciidoctor::Converter
  register_for 'text'
  def initialize *args
    super
    outfilesuffix '.txt'
  end
  def convert node, transform = nil, opts = nil
    case (transform ||= node.node_name)
    when 'document', 'section'
      [node.title, node.content].join %(\n\n)
    when 'paragraph'
      (node.content.tr ?\n, ' ') << ?\n
    else
      (transform.start_with? 'inline_') ? node.text : node.content
    end
  end
end

options = { attributes: [], output: '-' }
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby asciidoc-coalescer.rb [OPTIONS] FILE'
  opts.on('-a', '--attribute key[=value]', 'A document attribute to set in the form of key[=value]') do |a|
    options[:attributes] << a
  end
  opts.on('-o', '--output FILE', 'Write output to FILE instead of stdout.') do |o|
    options[:output] = o
  end
end.parse!

unless (source_file = ARGV.shift)
  warn 'Please specify an AsciiDoc source file to coalesce.'
  exit 1
end

unless (output_file = options[:output]) == '-'
  if (output_file = File.expand_path output_file) == (File.expand_path source_file)
    warn 'Source and output cannot be the same file.'
    exit 1
  end
end

doc = Asciidoctor.load_file source_file, safe: :unsafe, header_only: true, backend: :text, attributes: options[:attributes]
header_attr_names = (doc.instance_variable_get :@attributes_modified).to_a
header_attr_names.each {|k| doc.attributes[%(#{k}!)] = '' unless doc.attr? k }
=begin
def translate_block(block)
  if block.respond_to? :lines
    block.lines = block.lines
    .map{ |line| line.gsub(%r{latexmath:\[\$(.*[^\\])\$\]}, 'latexmath:[\1]')}
    .map{ |line| line.gsub(%r{latexmath:\[\\\[(.*[^\\])\\\]}) { |m|
      ['[latexmath]',
      '++++',
      Regexp.last_match[1],
      '++++']
    }}
    .flatten
  end
  puts block.lines if block.respond_to? :lines
  translate_blocks(block.blocks) unless block.blocks.empty?
end

def translate_blocks(blocks)
  blocks.each{|block| translate_block block }
end

translate_blocks(doc.blocks)

doc.convert

if output_file == '-'
  puts doc.content
else
  File.open(output_file, 'w') {|f| f.write doc.content }
end
=end


doc = Asciidoctor.load_file source_file, safe: :unsafe, parse: false, attributes: doc.attributes


#lines = doc.reader.readlines

lines = []
lines = File.readlines(source_file).map { |line| line }

#
# Process Comments
#

lines = lines.map{ |line| if line.start_with? '%' then ("// " + line[1..-1]) else line end }

#
# Process Podcast links
#
lines = lines.map do |line|
#  line.gsub(/^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w.-]+)+[\w\-._~:\/?#\[\]@!$&'()*+,;=]+\[Podcast link\]$/) do |match_str|
    line.gsub(/(?:http(s)?:\/\/)?[^ ]+\[Podcastlink\]/) do |match_str|
    match_str.gsub!('[Podcastlink]', '')
    "podcast::#{match_str}[]"
  end
end

#
# Process math
# AsciiDoc and AsciiDoctor differ in how they specify latexmath, so we have to convert.
# http://discuss.asciidoctor.org/mathjax-and-latexmath-support-differences-to-Asciidoc-td3159.html)
#
lines = lines.map do |line|
  if line.include? 'latexmath'
    line = line.gsub(%r{latexmath:\[\$((?:(?!\$\]).)+)\$\]}, 'latexmath:[\1]')
    m = line.match(%r{latexmath:\[\\\[((?:(?!\\\]).)+)\\\]})
    if m
      line = [
        '[latexmath]',
        '++++',
        Regexp.last_match[1],
        '++++']
    end
  end
  line
end.flatten

#
# Process (LaTeX) includes
#
lines = lines.map do |line|
  m = line.match(%r{== include (.*)\.tex})
  if m
    line = [
      '[latexmath]',
      '++++',
      "include::#{m[1]}.tex[]",
      '++++'
    ]
  end
  line
end.flatten

#
# Process question/hint/answer blocks
#
directive_stack = []
lines = lines.each_with_index.map do |line, lineno|
  m = line.match(%r{=== (begin|end):(question|hint|answer)})

  if m
    beginend = m[1]
    kind = m[2]
    if beginend == 'begin'
      directive_stack.push({ kind: kind, lineno: lineno, content: [] })
    else
      s = directive_stack.pop
      if s.nil?
        puts "ERROR: end without a begin #{kind} at #{lineno}: #{line}"
      else
        if s[:kind] != kind
          puts "ERROR: unmatched #{kind} at #{lineno}; begin #{s[:kind]} on #{s[:lineno]}"
        else
          next ["[#{kind}]","....."] + s[:content] + ["....."]
        end
      end
    end
    next nil
  else
    top = directive_stack.last
    if top
      top[:content] << line
      next nil
    end
  end
  line
end.reject(&:nil?).flatten

if output_file == '-'
  puts lines
else
  File.open(output_file, 'w') { |f| f.write lines }
end

