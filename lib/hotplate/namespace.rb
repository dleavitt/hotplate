module Hotplate
  class Namespace
    attr_reader :name, :commands

    def initialize(name)
      @name = name
      @commands = {}
    end

    def desc(str = nil)
      return @desc unless str
      @desc = str
    end

    def command(name, &block)
      @commands[name] = Command.new(name, &block)
    end

    def call(ctx)
      o = Object.new
      @commands.each do |name, cmd|
        o.define_singleton_method name do |*args|
          cmd.call(ctx, *args)
        end
      end
      o
    end
  end
end