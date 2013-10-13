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
      # TODO: generate some object that has all of the commands on it
    end
  end
end