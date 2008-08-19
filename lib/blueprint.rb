['constants', 'core_ext', 'version'].each do |file|
  require File.join(File.dirname(__FILE__), 'blueprint', file)
end

module Blueprint
  extend Blueprint::Version
end
