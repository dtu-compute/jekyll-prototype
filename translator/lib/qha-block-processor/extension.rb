require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'
require 'pry'
require 'awesome_print'

include Asciidoctor

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
      s.prepend(Alph[r])
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
            #replaced = "Question %d.%d" % [chap, get_and_tally_counter_of(type, counter)]
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

Extensions.register(:qha) {
  tree_processor QuestionHintAnswerTreeprocessor

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


