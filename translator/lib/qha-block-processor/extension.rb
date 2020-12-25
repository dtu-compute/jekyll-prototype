require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'
require 'pry' unless RUBY_ENGINE == 'opal'
require 'awesome_print' unless RUBY_ENGINE == 'opal'

include Asciidoctor

require 'nokogiri' if RUBY_ENGINE != 'opal'

class InjectScriptAndStyle < Asciidoctor::Extensions::Postprocessor
  def process(document, output)
    doc = Nokogiri::HTML(output)
    head = doc.at_css 'head'
    doc.at_css('body')['onload'] = 'onLoad()'
    basedir = File.expand_path('../../', __FILE__)

    head.add_child(<<-'HTML'
<script type="text/x-mathjax-config">
MathJax.Hub.Config({
  "messageStyle": "none",
  "tex2jax": {
    "inlineMath": [
      [
        "\\(",
        "\\)"
      ]
    ],
    "displayMath": [
      [
        "\\[",
        "\\]"
      ]
    ],
    "ignoreClass": "nostem|nolatexmath"
  },
  "asciimath2jax": {
    "delimiters": [
      [
        "\\$",
        "\\$"
      ]
    ],
    "ignoreClass": "nostem|noasciimath"
  },
  "TeX": {
    "equationNumbers": {
      "autoNumber": "none"
    }
  }
})
</script>
    HTML
    )

    head.add_child(<<-HTML
    <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=TeX-MML-AM_HTMLorMML" />
    HTML
    )

    inject_stylesheet(head, File.join(basedir, 'css', 'exercise.css'))
    inject_stylesheet(head, File.join(basedir, 'css', 'quizQuestion.css'))

    inject_script(head, File.join(basedir, 'js', 'exercise.js'))

    inject_script(head, File.join(basedir, 'js', 'quizQuestion.js'))

    File.open("#{basedir}/js/exercise.js") do |file|
      doc.at_css('body').add_child(<<-HTML
<script type="text/javascript">

function ready(callbackFunc) {
  if (document.readyState !== 'loading') {
    // Document is already ready, call the callback directly
    callbackFunc();
  } else if (document.addEventListener) {
    // All modern browsers to register DOMContentLoaded
    document.addEventListener('DOMContentLoaded', callbackFunc);
  } else {
    // Old IE browsers
    document.attachEvent('onreadystatechange', function() {
      if (document.readyState === 'complete') {
        callbackFunc();
      }
    });
  }
}

ready(function () {
  Exercise.replaceHints();
  window.question = new QuizQuestion();
  if (window.MathJax) {
    window.MathJax.Hub.Queue(['Typeset', window.MathJax.Hub]);
  }
});

function onLoad() {};

                    </script>
HTML
)
    end

    doc.to_html
  end

  def inject_script(head, js_filename)
    File.open(js_filename) do |file|
      head.add_child(<<-HTML
<script type="text/javascript">
  #{file.read}
</script>
      HTML
      )
    end
  end

  def inject_stylesheet(head, css_filename)
    File.open(css_filename) do |file|
      head.add_child(<<-HTML
<style type="text/css">
  #{file.read}
</style>
      HTML
      )
    end
  end
end

module CoreExtensions
  module Asciidoctor
    module AbstractBlock
      protected def find_by_internal selector = {}, result = [], &block
        if ((any_context = !(context_selector = selector[:context])) || context_selector == @context) &&
            (!(style_selector = selector[:style]) || style_selector == @style) &&
            (!(role_selector = selector[:role]) || (has_role? role_selector)) &&
            (!(id_selector = selector[:id]) || id_selector == @id)
          if id_selector
            result.replace block_given? ? ((yield self) ? [self] : []) : [self]
            raise ::StopIteration
          elsif block_given?
            if (verdict = yield self)
              case verdict
              when :skip_children
                result << self
                return result
              when :skip
                return result
              else
                result << self
              end
            end
          else
            result << self
          end
        end
      end
    end
  end
end


# from https://stackoverflow.com/questions/14632304/generate-letters-to-represent-number-using-ruby
class Numeric
  Alph = ("A".."Z").to_a

  def alph
    s, q = "", self
    while true
      (q, r = (q - 1).divmod(26))
      # Opal doesn't like this
#      s.prepend(Alph[r])
      s = Alph[r] + s
      break if q.zero?
    end
    s
  end
end


AbstractBlock.include CoreExtensions::Asciidoctor::AbstractBlock

# from https://raw.githubusercontent.com/asciidoctor/asciidoctor-extensions-lab/master/lib/autoxref-treeprocessor.rb
class QuestionHintAnswerTreeprocessor < Extensions::Treeprocessor
  def process document
    # The initial value of the chapter counter.
    initial_chapter = attr_of(document, 'autoxref-chapter') {1}

    # The section level we should treat as chapters.
    chapter_section_level = (document.attr 'qha-chaptersectlevel', 1).to_i

    # Reference number counter.  Reference numbers are reset by chapters.
    counter = {
        :chapter => initial_chapter,
        :section => 1,
        :question => 1,
    }

    seen = false

    # Scan for chapters.
    document.find_by(context: :section).each do |chapter|
      next unless not seen or chapter.level == chapter_section_level
      seen = true

      # XXX crude care for chapterless documents
      if chapter.level != chapter_section_level then
        chapter = document
      end

      # Assign chapter number and reset our reference numbers.
      chap = attr_of(chapter, 'qha-chapter') {get_and_tally_counter_of(:chapter, counter)}
      counter.update(
          {
              :section => 1,
              :question => 1,
          }
      )

      # Scan for sections, titled images/listings/tables in the chapter.
      [:question].each do |type|
        chapter.find_by(role: type).each do |el|
#              binding.pry
# puts "finding questions #{el.context} #{counter.ai}"
          if el.title?
            #replaced = "QuizQuestion %d.%d" % [chap, get_and_tally_counter_of(type, counter)]
            replaced = get_and_tally_counter_of(type, counter).alph
            replaced_caption = replaced + ' '
            el.title = replaced
            el.attributes['id'] = el.id = "#{chapter.id}_q#{counter[:question]}"
            el.attributes['caption'] = replaced_caption
            el.caption = replaced_caption
            document.references[:ids][el.attributes['id']] = replaced
          end
        end
      end
    end
    nil
  end

  # Gets and increments the value for the given type in the given
  # counter.
  def get_and_tally_counter_of type, counter
    t = counter[type]
    counter[type] = counter[type] + 1
    t
  end

  # Retrieves the associated value for the given key. Lazily retrieve
  # default value if no attr is set on the given key.
  def attr_of target, key, &default
    begin
      (target.attr key, :none).to_i
    rescue NoMethodError
      if not default.nil? then
        default.call
      else
        0
      end
    end
  end
end

class PodcastBlockMacro < Extensions::BlockMacroProcessor
  use_dsl

  named :podcast

  def process parent, target, attrs
#    title_html = (attrs.has_key? 'title') ?
#                     %(<div class="title">#{attrs['title']}</div>\n) : nil

    html = %(<div class="openblock podcast">
<pre>#{target}</pre>
</div>)

    create_pass_block parent, html, attrs, subs: nil
  end
end

class QuizAnswerBlockMacro < Extensions::BlockMacroProcessor
  use_dsl

  named :answer

  def process parent, target, attrs
    root = create_block parent, :pass, {}, { type: 'answer' }

    display = attrs[1]
    answer = attrs[2]
    parent_kind = attrs[:parent_kind]

    root << Asciidoctor::Block.new(parent, :open, {'role' => 'quiz-display-text'})
    root << Asciidoctor::Block.new(parent, :open, {'role' => 'quiz-answer-text'})

    parse_content root.blocks[0], Asciidoctor::Reader.new(display)
    parse_content root.blocks[1], Asciidoctor::Reader.new(answer) if answer

    mode = %w[right wrong].include?(target) ? target : nil

    root.blocks[0].blocks[0].attributes['role'] = 'quiz-display-text ' unless root.blocks[0]&.blocks&.[](0).nil?
    root.blocks[1].blocks[0].attributes['role'] = 'quiz-answer-text'   unless root.blocks[1]&.blocks&.[](0).nil?

    html = %(
    <div class="quiz-answer #{ mode ? ('quiz-answer-' + mode) : '' }">
      <label> <input type="#{parent_kind == 'mc' ? 'radio' : 'checkbox' }"> #{root.blocks[0].content} </label>
      <span> #{root.blocks[1].content} </span>
    </div>
    )
    create_block parent, :pass, html, { type: 'answer', role: mode }
  end
end

Extensions.register(:qha) {
  # TODO: move this to its own file
  block_macro PodcastBlockMacro

  block_macro QuizAnswerBlockMacro

  tree_processor QuestionHintAnswerTreeprocessor

  postprocessor InjectScriptAndStyle unless RUBY_ENGINE == 'opal'

  %i[question hint answer].each do |el_type|
    block {
    named el_type
    on_context :literal
    parse_content_as :raw
    process do |parent, reader, attrs|
      # TODO assume header if second line is blank
      result_lines = reader.source.chomp.split "\n"

      through_attrs = %w[id role title].inject({}) {|collector, key|
        collector[key] = attrs[key] if attrs.has_key? key
        collector
      }.merge('role' => el_type.to_s)

      #content = ['question'].concat result_lines
      content = result_lines

      wrapper = create_open_block parent, content, through_attrs

      wrapper.style = el_type.to_s
      wrapper.title = el_type.to_s[0]
      wrapper
    end
  }
  end
}


