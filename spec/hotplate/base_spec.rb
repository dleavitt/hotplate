require "spec_helper"

describe Hotplate::Base do
  before do
    @proc = proc { $namespace = self; "ns!" }
    @hotplate = Hotplate::Base.new
    @ns = @hotplate.namespace(:base_test, &@proc)
  end

  describe "#namespace" do
    it "names its namespaces correctly" do
      @hotplate.namespaces.keys.must_equal [:base_test]
    end

    it "calls the block passed to the namespace in the correct context" do
      @hotplate.namespaces[:base_test].must_equal $namespace
    end

    it "returns the namespace" do
      @hotplate.namespaces[:base_test].must_equal @ns
    end

    it "reopens a previously opened namespace" do
      ns1 = @hotplate.namespace(:ns_reopen) { @a = 1 }
      ns2 = @hotplate.namespace(:ns_reopen) { @b = 1 }
      ns1.must_equal ns2
    end
  end

  describe "#module" do
    it "adds new namespaces as instance methods the module" do
      cls = Class.new
      instance = cls.new
      instance.wont_respond_to(:base_test)
      cls.send :include, @hotplate.module
      instance.must_respond_to(:base_test)
    end

    it "doesn't generate a new module every time" do
      m = @hotplate.module
      @hotplate.namespace(:ns_moduletest) { @a = 1 }
      @hotplate.module.must_equal m
    end
  end
end