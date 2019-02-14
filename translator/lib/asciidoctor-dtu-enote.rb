ext_filenames = %w[
qha-block-processor/extension
]

ext_filenames.each{ |ext| RUBY_ENGINE == 'opal' ? (require ext) : (require_relative ext) }


