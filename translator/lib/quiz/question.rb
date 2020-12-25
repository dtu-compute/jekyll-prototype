require_relative 'extensions'


Asciidoctor::Extensions.register do
  require_relative 'question/extension'

  if document.basebackend? 'html' and not document.backend == 'pdf'
    block Asciidoctor::Question::HTMLQuestionBlockProcessor, :question
    postprocessor Asciidoctor::Question::HTMLPostProcessor
  end

  block Asciidoctor::Question::PDFQuestionBlockProcessor, :question if document.backend == 'pdf'
end
