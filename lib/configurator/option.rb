module Configurator
  module Option
    def option(name, default = nil, &block)
      config.add_option(name, block_given? ? Configuration.new : default)
      if block_given?
        config.get(name).instance_exec(config.get(name), &block)
      end
    end
    private :option

    def options(*names)
      names.each {|name| option(name) }
    end
    private :options
  end
end
