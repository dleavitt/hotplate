module Hotplate
  class Command
    attr_reader :ctx, :desc

    def initialize(name, &block)
      @name = name
      instance_eval(&block)
    end

    def metadata(data)
      data = Hashie::Mash.new(data.is_a?(String) ? YAML.load(data) : data)
      desc data[:desc] if data[:desc]
      opts data[:opts] if data[:opts]
    end

    def opts(data = nil)
      @options ||= Hashie::Mash.new
      return @options unless data
      @options.merge!(data)
    end

    def desc(str = nil)
      return @desc unless str
      @desc = str
    end

    def defaults
      Hashie::Mash.new Hash[opts.map { |n, m| [n, m[:default] || m["default"]] }]
    end

    def run(&block)
      @run_block = block
    end

    def call(ctx, options = {})
      raise "Run block required" unless @run_block
      options = OpenStruct.new(validate_options(merge_options(options)))

      ctx.instance_exec(options, &@run_block)
    end

    def merge_options(options)
      defaults.merge(Hashie::Mash.new(options))
    end

    def validate_options(options)
      errors = {}

      opts.each do |name, meta|
        if meta[:required] && options[name].nil?
          errors[name] ||= []
          errors[name] << :required
        end

        if meta[:choices] && ! meta[:choices].include?(options[name])
          errors[name] ||= []
          errors[name] << :invalid
        end
      end

      options.each do |name, value|
        unless opts.has_key?(name)
          errors[name] ||= []
          errors[name] << :unknown
        end
      end

      raise OptionsError.new(errors) if errors.any?

      options
    end
  end

  class OptionsError < StandardError
    attr_accessor :errors

    def initialize(errors)
      @errors = errors
    end

    def to_s
      msgs = errors.flat_map do |name, errors|
        errors.map do |error|
          "option '#{name}' is #{error}"
        end
      end

      msgs.join(", ")
    end
  end
end