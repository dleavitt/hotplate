module Hotplate
  class Base
    attr_reader :namespaces, :module

    def initialize
      @namespaces = {}
      @module = Module.new
    end

    def namespace(name, &block)
      ns = (@namespaces[name] ||= Namespace.new(name)).tap do |ns|
        ns.instance_exec(&block)
        @module.send :define_method, name do
          ns.call(self)
        end
      end
    end

    alias_method :ns, :namespace
  end
end