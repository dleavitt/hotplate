require "spec_helper"

describe Hotplate::Namespace do
  before do
    @hotplate = Hotplate::Base.new

    @ns = @hotplate.namespace :ns_test do
      desc "Namespace Testing"
    end
  end

  describe "#desc" do
    it "gets the desc" do
      @ns.desc.must_equal "Namespace Testing"
    end

    it "updates the desc" do
      @ns.desc("New desc")
      @ns.desc.must_equal "New desc"
    end
  end

  describe "#command" do
    before do
      @cmd = @ns.command(:ns_cmd) { $ns_cmd_body = 1; @a = 1 }
    end

    it "names the command correctly" do
      @ns.commands.keys.must_equal [:ns_cmd]
    end

    it "instantiates a command" do
      @ns.commands[:ns_cmd].must_be_kind_of Hotplate::Command
    end

    it "returns the command it instantiates" do
      @ns.commands[:ns_cmd].must_equal @cmd
    end

    it "overwrites the old command with a new one if called twice" do
      cmd2 = @ns.command(:ns_cmd) { @b = 1 }
      cmd2.wont_equal @cmd
    end

    it "runs the command body" do
      @ns.command(:ns_cmd2) { $ns_cmd2_body = 1 }
      $ns_cmd2_body.must_equal 1
    end
  end
end