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

  describe "dsl" do
    before do
      Hotplate.ns :dsl do
        command :simple do
          desc "Test desc"
          opts a: { default: 1 }, b: { default: 1 }
          run { |o| $simple_ran = true; $simple_self = self; $simple_opts = o }
        end

        command :complex do
          metadata <<-YAML
            desc: This is the "complex" description
            opts:
              required_param:
                required: true
                description: required_param description
              required_boolean_param:
                required: true
                choices: [true, false]
              choice_param:
                choices: [1, 2, 3]
                description: choice_param description
              default_param:
                default: 1
                choices: [1, 2]
          YAML
        end
      end

      Hotplate.ns :dsl2 do
        command :test2 do
          desc "Test desc2"
        end
      end

      cls = Class.new
      cls.send :include, Hotplate.dsl
      @o = cls.new
    end

    it "makes the namespaces callable" do
      @o.must_respond_to :dsl
      @o.must_respond_to :dsl2
    end

    it "makes the commands callable" do
      @o.dsl.must_respond_to :simple
      @o.dsl.must_respond_to :complex
      @o.dsl2.must_respond_to :test2
    end

    it "calls the run block in the command with ctx and opts" do
      $simple_ran = nil
      $simple_self = nil
      $simple_opts = nil
      @o.dsl.simple(b: 2)
      $simple_ran.must_equal true
      $simple_self.must_equal @o
      $simple_opts.a.must_equal 1
      $simple_opts.b.must_equal 2
    end
  end
end