require "sshkit"
require "yaml"
require "hashie/mash"
require "ostruct"

require_relative "hotplate/version"
require_relative "hotplate/base"
require_relative "hotplate/namespace"
require_relative "hotplate/command"

module Hotplate
  def self.dsl
    @base ||= Base.new
    @base.module
  end

  def self.ns(name, &block)
    @base ||= Base.new
    @base.ns(name, &block)
  end
end
