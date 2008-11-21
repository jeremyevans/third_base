require 'rake'
require 'rake/clean'
begin
  require "hanna/rdoctask"
rescue LoadError
  require "rake/rdoctask"
end

ENV['RUBYLIB'] = "#{File.join(File.dirname(__FILE__), 'lib')}:#{ENV['RUBYLIB']}"
CLEAN.include ['rdoc', '*.gem']

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += ["--quiet", "--line-numbers", "--inline-source", '--title', \
    'ThirdBase: A Fast and Easy Date/DateTime Class', '--main', 'README']
  rdoc.rdoc_files.add %w"README LICENSE lib/**/*.rb"
end

desc "Update docs and upload to rubyforge.org"
task :website => [:rdoc]
task :website do
  sh %{chmod -R g+w rdoc/*}
  sh %{scp -rp rdoc/* rubyforge.org:/var/www/gforge-projects/third-base}
end

desc "Package third_base"
task :package do
  sh %{gem build third_base.gemspec}
end

desc "Run specs"
task :default => [:spec_date, :spec_datetime, :spec_compat]
task :spec_date do
  sh %{mspec -I lib spec/date/*_spec.rb}
end
task :spec_datetime do
  sh %{mspec -I lib spec/datetime/*_spec.rb}
end
task :spec_compat do
  sh %{mspec -I lib spec/compat/*_spec.rb}
end

desc "Run benchmarks"
task :bench do
  sh %{ruby benchmark/date.rb}
  sh %{ruby benchmark/datetime.rb}
end
