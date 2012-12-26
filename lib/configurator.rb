require 'configurator/option'

module Configurator
  autoload :Configuration, 'configurator/configuration'
  include Option

  def self.extended(base)
    base.class_eval { remove_instance_variable(:@configuration) if defined? @configuration }
  end

  def config(&block)
    @configuration ||= Configuration.new
    if block_given?
      @configuration.instance_exec(@configuration, &block)
    end
    @configuration
  end
end
