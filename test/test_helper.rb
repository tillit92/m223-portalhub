ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

# Minitest 6 bringt keine Stub-Helfer mehr mit. Ersetzt eine Methode auf genau
# einem Objekt, solange der Block läuft, und stellt sie danach wieder her.
module Stubbing
  def stubbing(object, name, replacement)
    object.define_singleton_method(name, &replacement)
    yield
  ensure
    object.singleton_class.remove_method(name)
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
