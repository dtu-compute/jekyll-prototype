require 'asciidoctor' unless RUBY_ENGINE == 'opal'# || defined?(::Asciidoctor::VERSION)
require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

require_relative '../../asciidoctor-question/lib/asciidoctor-question/version'

module Asciidoctor
  module Question
    module Extensions
      class BaseProcessor < Asciidoctor::Extensions::BlockProcessor
        use_dsl

        def self.inherited(subclass)
          subclass.option :contexts, [:example, :literal, :open]
          subclass.option :content_model, :simple
        end

        def process_error(parent, err, source_lines)
          lines = ['[NOTE]', '====', 'Error ' + err, '====']
          block = Asciidoctor::Parser.next_block Asciidoctor::Reader.new(lines), parent
          block.blocks.push Asciidoctor::Parser.next_block Asciidoctor::Reader.new(['[source, asciidoc]', '----'] + source_lines + ['----']), block
          block
        end

        def process_error_push(parent, err, source_lines)
          parent.blocks.push process_error parent, err, source_lines
        end

        def post_answers(parent, tag)
          id = tag[:id]
          parent.blocks.push Asciidoctor::Block.new parent, :pass, :source => "
            <p style=\"margin-bottom: 25px\">
              <button onclick='QuizQuestion.resolve(#{id})'>resolve</button>
              <button onclick='QuizQuestion.reset(#{id})'>reset</button>
            </p>"
          parent
        end
      end
    end
  end
end
