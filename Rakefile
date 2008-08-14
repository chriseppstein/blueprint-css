require 'rubygems'
require 'rake'

# ----- Default: Testing ------

task :default => :tests

require 'rake/testtask'
require 'fileutils'

Rake::TestTask.new :tests do |t|
  t.libs << 'lib'
  test_files = FileList['tests/**/*_test.rb']
  test_files.exclude('tests/rails/*', 'tests/haml/*')
  t.test_files = test_files
  t.verbose = true
end
Rake::Task[:tests].send(:add_comment, <<END)
To run with an alternate version of Rails, make test/rails a symlink to that version.
To run with an alternate version of Haml & Sass, make test/haml a symlink to that version.
END

task :blueprint do
  linked_haml = "tests/haml"
  if File.exists?(linked_haml) && !$:.include?(linked_haml + '/lib')
    puts "[ using linked Haml ]"
    $:.unshift linked_haml + '/lib'
  end
  require 'haml'
  require 'sass'
  require 'pathname'
  FileList["examples/default/stylesheets/*.sass"].each do |sass_file|
    basename = sass_file[("examples/default/stylesheets/".length)..-6]
    css_filename = "blueprint/#{basename}.css"
    blueprint_sass = File.dirname(__FILE__).sub(%r{.*/},'')
    engine = Sass::Engine.new(open(sass_file).read,
                                :filename => sass_file,
                                :css_filename => css_filename,
                                :style => :compact,
                                :load_paths => ["examples/default/stylesheets", "#{File.dirname(__FILE__)}/src"])
    FileUtils.mkdir_p(File.dirname(css_filename))
    output = open(css_filename,'w')
    output.write(<<HEADER)
/*****************************************************************#{'*'*(sass_file.length)}
 * This file was generated from #{sass_file}. Editing it is not recommended. *
 * Instead modify #{sass_file} and then run 'rake blueprint'                 *
 * For help on editing sass files go to:                         #{' '*(sass_file.length)}*
 *   http://haml.hamptoncatlin.com/docs/rdoc/classes/Sass.html   #{' '*(sass_file.length)}*
 *****************************************************************#{'*'*(sass_file.length)}/
HEADER
    output.write(engine.render)
    output.close
    puts "Generated #{css_filename}"
  end
end

desc "Compile Examples into HTML and CSS"
task :examples do
  linked_haml = "tests/haml"
  if File.exists?(linked_haml) && !$:.include?(linked_haml + '/lib')
    puts "[ using linked Haml ]"
    $:.unshift linked_haml + '/lib'
  end
  require 'haml'
  require 'sass'
  require 'pathname'
  FileList['examples/*'].each do |example|
    puts "Compiling #{example} -> built_examples/#{example.sub(%r{.*/},'')}"
    # compile any haml templates to html
    FileList["#{example}/*.haml"].each do |haml_file|
      basename = haml_file[9..-6]
      engine = Haml::Engine.new(open(haml_file).read, :filename => haml_file)
      target_dir = "built_examples/#{basename.sub(%r{/[^/]*$},'')}"
      FileUtils.mkdir_p(target_dir)
      output = open("built_examples/#{basename}",'w')
      output.write(engine.render)
      output.close
    end
    # compile any sass templates to css
    FileList["#{example}/stylesheets/**/[^_]*.sass"].each do |sass_file|
      basename = sass_file[9..-6]
      css_filename = "built_examples/#{basename}.css"
      blueprint_sass = File.dirname(__FILE__).sub(%r{.*/},'')
      engine = Sass::Engine.new(open(sass_file).read,
                                  :filename => sass_file,
                                  :line_comments => true,
                                  :css_filename => css_filename,
                                  :load_paths => ["#{example}/stylesheets", "#{File.dirname(__FILE__)}/src"])
      target_dir = "built_examples/#{basename.sub(%r{/[^/]*$},'')}"
      FileUtils.mkdir_p(target_dir)
      output = open(css_filename,'w')
      output.write(engine.render)
      output.close      
    end
    # copy any other non-haml and non-sass files directly over
    target_dir = "built_examples/#{example.sub(%r{.*/},'')}"
    other_files = FileList["#{example}/**/*"]
    other_files.exclude "**/*.sass", "*.haml"
    other_files.each do |file|
      
      if File.directory?(file)
        FileUtils.mkdir_p(file)
      elsif File.file?(file)
        target_file = "#{target_dir}/#{file[(example.size+1)..-1]}"
        # puts "mkdir -p #{File.dirname(target_file)}"
        FileUtils.mkdir_p(File.dirname(target_file))
        # puts "cp #{file} #{target_file}"
        FileUtils.cp(file, target_file)
      end
    end
  end
end