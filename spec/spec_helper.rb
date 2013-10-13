require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'hotplate'

# Hotplate.ns :test do
#   command :run do
#     metadata <<-YAML
#       desc: This is the "run" description
#       opts:
#         required_param:
#           required: true
#           description: required_param description
#         required_boolean_param:
#           required: true
#           choices: [true, false]
#         choice_param:
#           default: true
#           choices: [1, 2, 3]
#           description: choice_param description
#         default_param:
#           default: false
#           choices: [true, false]
#     YAML
#   end
# end