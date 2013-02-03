require 'configurator/option'

module Configurator
  class Configuration < Hash
    include Option

    def add_option(name, default, &block)
      defaults[name.to_sym] = default || block
    end

    def config
      self
    end

    def defaults
      @defaults ||= {}
    end

    def initialize(options = {})
      options.each do |key, value|
        set(key, value)
      end
    end

    def get(name)
      name = name.to_sym
      value = self.key?(name) ? self[name] : defaults[name]
      if value.respond_to? :call
        value = value.call
      end
      value
    end

    def set(name, value, &block)
      name = name.to_sym
      if block_given?
        self[name] ||= defaults[name] || self.class.new
        self[name].instance_eval(&block)
      elsif value.is_a?(Hash)
        self[name] = defaults[name] || self.class.new
        value.each do |key, value_two|
          self[name].send("#{key}=", value_two)
        end
      else
        self[name] = value
      end
    end

    private
    def method_missing(method, *args, &block)
      method_name = method.to_s
      setter = method_name.chomp!('=') || !args.empty? || block_given?
      if setter
        set(method_name, args.first, &block)
      else
        get(method)
      end
    end
  end
end
