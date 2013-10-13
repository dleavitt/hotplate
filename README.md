# Hotplate

An experiment in building DerpOps tooling on top of SSHKit.

## Installation

Add this line to your application's Gemfile:

    gem 'hotplate'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hotplate

## Usage

TODO: Write usage instructions here

## Goals

To see if I can emulate some of Ansible's elegance and power, while avoiding some of its questionable design decisions.

- YAML for inventory; Ruby for tasks.
- Modules should be as easy to write as tasks.
- Modules should be composable.
- Modules and tasks should be amenable to package management (Rubygems.)
- The whole system should be scriptable and useable as a library.
- Everything should be really slow :/ speed can come later.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
