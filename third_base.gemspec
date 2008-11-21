spec = Gem::Specification.new do |s|
  s.name = "third_base"
  s.version = "1.0.0"
  s.author = "Jeremy Evans"
  s.email = "code@jeremyevans.net"
  s.homepage = "http://third-base.rubyforge.org"
  s.platform = Gem::Platform::RUBY
  s.summary = "A Fast and Easy Date/DateTime Class"
  s.files = %w'LICENSE README bin/third_base' + Dir['{lib,benchmark,spec}/**/*.rb']
  s.require_paths = ["lib"]
  s.executables = ["third_base"]
  s.has_rdoc = true
  s.rdoc_options = %w'--inline-source --line-numbers README LICENSE lib'
  s.rubyforge_project = 'third-base'
end
