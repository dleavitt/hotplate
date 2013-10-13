require_relative "../hotplate"

Dir["commands/*.rb"].each(&method(:require))