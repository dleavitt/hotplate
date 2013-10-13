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
      Hashie::Mash.new Hash[opts.map { |n, m| [n, m[:default]] }]
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
      options = Hashie::Mash.new(options)
      errors = {}

      opts.each do |name, meta|
        if meta[:required] && options[name].nil?
          errors[name] = :required
        elsif ! options[name].nil? && meta[:choices] && ! meta[:choices].include?(options[name])
          errors[name] = :invalid
        end
      end

      options.each do |name, value|
        errors[name] = :unknown unless opts.has_key?(name)          
      end

      raise OptionsError.new(errors) if errors.any?

      options
    end
  end

  class OptionsError < StandardError
    attr_accessor :errors

    def initialize(errors)
      @errors = Hashie::Mash.new(errors)
    end

    def to_s
      errors.map { |name, error| "option '#{name}' is #{error}" }.join(", ")
    end
  end
end