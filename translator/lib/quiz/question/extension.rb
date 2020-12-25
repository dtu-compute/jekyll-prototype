
require_relative '../extensions'
require_relative '../multiple_choice/extension'
require_relative '../gap/extension'

module Asciidoctor
  module Question
    class QuestionBlockProcessor < Extensions::BaseProcessor
      name_positional_attributes [:type, :shuffle]

      MULTIPLE_CHOICE_TYPES =  %w[all_that_apply multiple_choice].freeze
      GAP_TYPES =  %w[gap].freeze

      def initialize name = nil, config = {}
        super name, config
        @@id = 0
      end

      def process(parent, source, tag)
        tag[:id] = @@id = @@id + 1

        tag[:solution] = has_solution parent

        if MULTIPLE_CHOICE_TYPES.include?(tag[:type])
          block = process_question_mc parent, source, tag
        elsif GAP_TYPES.include?(tag[:type])
          block = process_question_gap parent, source, tag
        else
          block = process_error parent, "missing or invalid question type #{tag[:type]}", source.lines
        end

        block
      end

      def has_solution(parent)
        if not ( parent.document.attributes['solution'].nil? and parent.attributes['solution'].nil? )
          true
        else
          if parent.parent.nil?
            false
          else
            has_solution(parent.parent)
          end
        end
      end
    end


    class HTMLQuestionBlockProcessor < QuestionBlockProcessor
      name_positional_attributes [:type, :shuffle]

      def process_question_mc parent, source, tag
        HTMLMultipleChoiceBlockProcessor.new.process parent, source, tag
      end

      def process_question_gap parent, source, tag
        HTMLGAPBlockProcessor.new.process parent, source, tag
      end
    end


    class PDFQuestionBlockProcessor < QuestionBlockProcessor
      name_positional_attributes [:type, :shuffle]

      def process_question_mc parent, source, tag
        PDFMultipleChoiceBlockProcessor.new.process parent, source, tag
      end

      def process_question_gap parent, source, tag
        PDFGAPBlockProcessor.new.process parent, source, tag
      end
    end
  end
end
