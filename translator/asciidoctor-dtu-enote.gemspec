Gem::Specification.new do |s|
  s.name = %q{asciidoctor-dtu-enote}
  s.authors = ['Iain J. Bryson']
  s.version = "0.0.1"
  s.date = %q{2019-02-11}
  s.summary = %q{Asciidoctor extensions for the DTU eNote project}
  s.files = Dir.glob("{bin,lib}/**/*")# + %w(LICENSE README.md ROADMAP.md CHANGELOG.md)
  s.require_paths = ["lib"]
  s.add_dependency "asciidoctor", "~> 1.5"
  s.add_dependency "pry", "~> 0.12.2"
  s.add_dependency "awesome_print", "~> 1.8"
end
