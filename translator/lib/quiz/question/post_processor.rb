
  module Asciidoctor
    module Question
      class HTMLPostProcessor < Asciidoctor::Extensions::Postprocessor
        def process(document, output)
          output.split(/\n/)
            .reject{ |l| l.match(/^\s*<p><\/p>\s*$/) }
            .map{ |l| l.gsub(/id=\"quiz-question_(\d+)_type=([a-z]+)_?(shuffle)?\"/,
            'id="quiz-question-\1" data-question-id="\1" data-question-type="\2" data-question-shuffle="\3"')}
            .join("\n")
        end
      end
    end
  end
