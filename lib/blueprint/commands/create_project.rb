module Blueprint
  module Commands
    class CreateProject
      
      attr_accessor :working_directory, :project_name, :options

      def initialize(working_directory, options = {})
        self.working_directory, self.options = working_directory, options
        self.project_name = options[:project_name]
      end
      
      def perform
        puts "Creating project #{project_name} in #{working_directory}"
      end

    end
  end
end