require 'rubygems'
require 'bundler'
Bundler.require(:default, :jekyll_plugins)
require 'asciidoctor'
require 'asciidoctor-dtu-enote'
#require '../translator/lib/qha-block-processor/extension.rb'

puts 'hello'
ap 'hello'

puts Asciidoctor
puts QuestionHintAnswerTreeprocessor