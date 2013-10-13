Hotplate.namespace :apt do
  command :install do
    metadata <<-YAML
      desc: Installs apt packages on Debian/Ubuntu
      opts:
        package:
          required: true
          description: Package name or specifier
        install_recommends:
          default: true
          choices: [true, false]
          description: Sets the --no-install-recommends flag for apt
        force:
          default: false
          choices: [true, false]
    YAML

    run do |c|
      binding.pry
    end
end