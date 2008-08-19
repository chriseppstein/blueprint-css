module Blueprint
  module Commands
    class UpdateProject
      
      attr_accessor :project_directory, :project_name, :options

      def initialize(working_directory, options = {})
        self.options = options
        if options[:project_name]
          options[:project_name] = options[:project_name][0..-2] if options[:project_name][-1..-1] == File::SEPARATOR
          self.project_name = File.basename(options[:project_name])
          if File.directory?(options[:project_name])
            self.project_directory = options[:project_name]
          elsif File.directory?(File.join(working_directory, options[:project_name]))
            self.project_directory = options[:project_name]
          else
            if File.exists?(options[:project_name]) or File.exists?(File.join(working_directory, options[:project_name]))
              raise ::Blueprint::Exec::ExecError.new("#{options[:project_name]} is not a directory.")
            else
              raise ::Blueprint::Exec::ExecError.new("#{options[:project_name]} does not exist.")
            end
          end
        else
          self.project_name = File.basename(working_directory)
          self.project_directory = working_directory          
        end
      end
      
      def perform
        puts "Updating project #{project_name} in #{project_directory}"
      end

    end
  end
end