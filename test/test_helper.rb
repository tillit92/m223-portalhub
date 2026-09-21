ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

# Minitest 6 no longer ships stubbing helpers. Replaces one method on one
# object while the block runs and puts the original back afterwards.
module Stubbing
  def stubbing(object, name, replacement)
    singleton = object.singleton_class
    original = singleton.instance_method(name) if singleton.method_defined?(name, false)

    object.define_singleton_method(name, &replacement)
    yield
  ensure
    singleton.remove_method(name) if singleton.method_defined?(name, false)
    singleton.define_method(name, original) if original
  end
end

module ActiveSupport
  class TestCase
    include Stubbing

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
