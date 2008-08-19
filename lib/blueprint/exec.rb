require 'optparse'
require 'rubygems'
require 'haml'

module Blueprint
  module Exec
    class ExecError < StandardError
    end
    class Blueprint
      
      attr_accessor :args, :options, :opts

      def initialize(args)
        self.args = args
        self.options = {}
      end

      def run!
        begin
          parse!
          perform!
        rescue Exception => e
          raise e if e.is_a? SystemExit
          if e.is_a? ExecError
            $stderr.puts e.message
          else
            $stderr.puts "#{e.class} on line #{get_line e} of #{get_file e}: #{e.message}"
            if @options[:trace]
              e.backtrace[1..-1].each { |t| $stderr.puts "  #{t}" } 
            else
              $stderr.puts "Run with --trace to see the full backtrace"
            end
          end
          exit 1
        end
        exit 0
      end
      
      protected
      
      def perform!
        if options[:update]
          do_command(:update_project)
        elsif options[:project_name]
          do_command(:create_project)
        else
          puts self.opts
        end
      end
      
      def parse!
        self.opts = OptionParser.new(&method(:set_opts))
        self.opts.parse!(self.args)    
        if ARGV.size > 0
          self.options[:project_name] = ARGV.shift
        end
        self.options[:environment] ||= :production
      end
      
      def set_opts(opts)
        opts.banner = <<END
Usage: blueprint [options] [project]

Description:
  When project is given, generates a new project of that name as a subdirectory of
  the current directory.
  
  When project is ommitted, one of the following options must be present.

Options:
END
        opts.on('-u', '--update', :NONE, 'Update the current project') do
          self.options[:update] = true
        end

        opts.on('-f', '--force', :NONE, 'Force. Allows some commands to succeed when they would otherwise fail.') do
          self.options[:force] = true
        end

        opts.on('-e ENV', '--environment ENV', [:development, :production], 'Select an output mode (development, production)') do |env|
          self.options[:environment] = env
        end

        opts.on('--dry-run', :NONE, 'Dry Run. Tells you what it plans to do.') do
          self.options[:dry_run] = true
        end

        opts.on('--trace', :NONE, 'Show a full traceback on error') do
          self.options[:trace] = true
        end
        
        opts.on_tail("-?", "-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail("-v", "--version", "Print version") do
          puts("Blueprint-CSS #{::Blueprint.version[:string]}")
          exit
        end        
      end

      def get_file(exception)
        exception.backtrace[0].split(/:/, 2)[0]
      end

      def get_line(exception)
        # SyntaxErrors have weird line reporting
        # when there's trailing whitespace,
        # which there is for Haml documents.
        return exception.message.scan(/:(\d+)/)[0] if exception.is_a?(::Haml::SyntaxError)
        exception.backtrace[0].scan(/:(\d+)/)[0]
      end
      
      def do_command(command)
        require File.join(File.dirname(__FILE__), 'commands', command.to_s)
        command_class_name = command.to_s.split(/_/).map{|p| p.capitalize}.join('')
        command_class = eval("::Blueprint::Commands::#{command_class_name}")
        command_class.new(Dir.getwd, options).perform
      end

    end
  end
end
