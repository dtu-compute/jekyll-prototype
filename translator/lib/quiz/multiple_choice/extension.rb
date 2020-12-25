require_relative '../extensions'

module Asciidoctor
  module Question

    class MultipleChoiceBlockProcessor < Extensions::BaseProcessor

      name_positional_attributes [:type, :shuffle]

      def process(parent, source, tag)
        begin
          id = tag[:id]

          kind = 'mc' if tag[2] == 'multiple_choice'
          kind = 'ata' if tag[2] == 'all_that_apply'

          raise StandardError.new("Invalid or unspecified question kind") if kind.nil?

          attrs = { 'id' => "quiz-question_#{id}_type=#{kind}", 'role' => "quiz-question-#{kind} quiz-question" }

          attrs['id'] += '_shuffle=shuffle' unless tag[:shuffle].nil?

          parser = Asciidoctor::Block.new parent, :open, {:attributes => attrs}

          reader = Asciidoctor::Reader.new(source.lines)

          parse_content parser, reader, { parent_kind: kind }

          answers, questions = parser.blocks.partition{|block| block&.attributes&.[](:type) == 'answer' }

          qanda = Asciidoctor::Block.new parent, :open, { attributes: attrs }

          questions.each { |question| qanda << question }

          answer_list = create_list qanda, :olist, { 'id' => 'foo', 'role' => "quiz-question-#{kind}" }
          answers.each do |answer|
            li = create_list_item answer_list
            li << answer
            answer_list << li
          end

          qanda << answer_list

          post_answers(qanda, tag) if kind == 'ata'

          qanda

        rescue => err
          ap err.backtrace
          new_parent = Asciidoctor::Block.new parent, :open

          process_error_push new_parent, err.message, source.lines
          new_parent
        end

      end
    end

    class PDFMultipleChoiceBlockProcessor < MultipleChoiceBlockProcessor
      def prepare_answers(answers_block, tag)
        super
        unless tag[:solution]
          answers_block.blocks.each do |answer|
            answer.attributes.delete('checked')
          end
        end
        answers_block
      end

      def post_answers(parent, tag)

      end
    end

    class HTMLMultipleChoiceBlockProcessor < MultipleChoiceBlockProcessor

      def prepare_answer_lines(lines)
        lines.map! do |answer|
          if answer =~ /^-\s?\[/ then
            answer.sub ']', '] +++ <span/> +++'
          else
            answer
          end
        end
        lines
      end

      def prepare_answers(answers_block, tag)
        id = tag[:id]
        aid = -1
        answers_block.attributes['id'] = "answers_mc_#{id}"

        answers_block.blocks.each do |answer|
          answer.attributes['id'] = "answer_mc_#{id}_#{aid += 1}"
        end
        answers_block
      end
    end
  end
end
