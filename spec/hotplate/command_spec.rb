require "spec_helper"

describe Hotplate::Command do
  before do
    @hotplate = Hotplate::Base.new

    @ns = @hotplate.namespace :cmd_test do
      desc "Namespace Testing"
    end
  end

  describe "#metadata" do
    before do
      desc = @desc = "Cmd desc"
      opts = @opts = {
        param1: {
          default: "a",
          desc: "Param desc",
          choices: [0, 1.0, "a"]
        }
      }

      yaml_metadata = <<-YAML
        desc: Cmd desc
        opts:
          params1:
            default: a
            desc: "Param desc"
            choices: [0, 1.0, a]
      YAML

      @cmd_hash = @ns.command(:cmd_hash) { metadata({opts: opts, desc: desc}) }
      @cmd_yaml = @ns.command(:cmd_yaml) { metadata yaml_metadata }
    end

    it "sets desc via hash" do
      @cmd_hash.desc.must_equal @desc
    end

    it "sets desc via yaml" do
      @cmd_yaml.desc.must_equal @desc
    end

    it "sets options via hash" do
      @cmd_hash.opts.must_equal Hashie::Mash.new @opts
    end

    it "sets options via yaml" do
      param1 = @cmd_yaml.opts[:params1]
      param1[:default].must_equal @opts[:param1][:default]
      param1[:choices].must_equal @opts[:param1][:choices]
      param1[:desc].must_equal @opts[:param1][:desc]
    end
  end

  describe "#call" do
    before do
      @cmd_run = @ns.command :cmd_hash do
        metadata opts: { p1: { default: 1 }, p2: { default: 2 }, p3: {} }
        run do |opts|
          $ran = true
          $runself = self
          $p1 = opts.p1
          $p2 = opts.p2
          $p3 = opts.p3
        end
      end

      @ctx = Object.new
    end

    it "runs the 'run' block" do
      $ran = false
      @cmd_run.call(@ctx)
      $ran.must_equal true
    end

    it "runs it in the correct context" do
      $runself = nil
      @cmd_run.call(@ctx)
      $runself.must_equal @ctx
    end

    it "passes options through" do
      $p1 = nil
      @cmd_run.call(@ctx, p1: 4)
      $p1.must_equal 4
      $p2.must_equal 2
    end
  end

  describe "#merge_options" do
    before do
      @def_cmd = @ns.command(:defaults_hash) do
        opts param1: { default: "def1" }, "param2" => { "default" => "def2" }
      end
    end

    it "merges string keys with symbol keys" do
      new_opts = @def_cmd.merge_options("param1" => "def3", param2: "def4")
      new_opts[:param1].must_equal new_opts["param1"]
      new_opts[:param2].must_equal new_opts["param2"]
    end

    it "sets defaults for undefined keys" do
      @def_cmd.merge_options({})[:param1].must_equal "def1"
      @def_cmd.merge_options({})[:param2].must_equal "def2"
    end

    it "allows explicitly set options to override the defaults" do
      new_opts = @def_cmd.merge_options(param1: "def3", param2: "def4")
      new_opts[:param1].must_equal "def3"
      new_opts[:param2].must_equal "def4"
    end

    it "overrides defaults even when keys are falsey" do
      new_opts = @def_cmd.merge_options(param1: false, param2: nil)
      new_opts[:param1].must_equal false
      new_opts[:param2].must_equal nil
    end
  end

  describe "#validate_options" do
    let(:ex_cls) { Hotplate::OptionsError }

    describe "required" do
      let(:cmd) { @ns.command(:cmd) { opts p1: { required: true } } }

      it "does not raise an error when a required option is supplied" do
        cmd.validate_options(p1: 1)[:p1].must_equal 1
      end

      it "raises an error when a required option is missing" do
        ex = -> { cmd.validate_options({}) }.must_raise ex_cls 
        ex.errors.p1.must_equal :required
      end
    end

    describe "choices" do
      let(:cmd) { @ns.command(:cmd) { opts p1: { choices: [1,2] } } }

      it "does not raise an error when an option is among the choices" do
        cmd.validate_options(p1: 1)[:p1].must_equal 1
      end

      it "raises an error when an option is not among the choices" do
        ex = -> { cmd.validate_options(p1: 3) }.must_raise ex_cls
        ex.errors.p1.must_equal :invalid
      end

      it "doesn't raise an error when an optional argument is omitted" do
        cmd.validate_options({})[:p1].must_equal nil
      end
    end
    
    it "raises an error when there are unknown options" do
      cmd = @ns.command(:cmd) { opts p1: { } }
      ex = -> { cmd.validate_options(p2: 1) }.must_raise ex_cls
      ex.errors.p2.must_equal :unknown
    end

    it "collects all errors when there are multiple" do
      cmd = @ns.command :cmd do
        opts p1: { required: true }, p2: { choices: [1,2] }
      end

      ex = -> { cmd.validate_options(p2: 3, p3: 1) }.must_raise ex_cls
      ex.errors.p1.must_equal :required
      ex.errors.p2.must_equal :invalid
      ex.errors.p3.must_equal :unknown
    end
  end


end