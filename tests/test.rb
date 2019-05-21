require 'rubygems'
require 'bundler'
Bundler.require(:default, :jekyll_plugins)

puts Asciidoctor
puts QuestionHintAnswerTreeprocessor

ADOC_ROOT='./adocs'

Dir.glob(File.join(ADOC_ROOT, "*.adoc")).each do |adoc|
  Asciidoctor.convert_file adoc, to_file: true, safe: :safe
end
