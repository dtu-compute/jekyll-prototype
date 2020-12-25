# Opal requires plain strings when require'ing -- seems metaprogramming is out :(
# ext_filenames = %w[
# qha-block-processor/extension
# ]

# ext_filenames.each{ |ext| RUBY_ENGINE == 'opal' ? (require_relative "#{ext}.rb") : (require_relative ext) }


# Opal.append_path File.expand_path('../asciidoctor-question/', __FILE__).untaint if RUBY_ENGINE == 'opal'

require_relative 'qha-block-processor/extension.rb'

require_relative 'quiz/extensions.rb'
require_relative 'quiz/question.rb'

require_relative 'quiz/multiple_choice/extension.rb'
require_relative 'quiz/question/extension.rb'
require_relative 'quiz/question/post_processor.rb'
require_relative 'quiz/gap/extension.rb'


