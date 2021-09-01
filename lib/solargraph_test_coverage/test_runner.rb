# frozen_string_literal: true

module SolargraphTestCoverage
  # Parent Class for different testing frameworks
  class TestRunner
    def self.with(test_file)
      case Config.test_framework
      when 'rspec'
        RSpecRunner.new(test_file)
      when 'minitest'
        MinitestRunner.new(test_file)
      end
    end

    def initialize(test_file)
      @test_file = test_file
      @result    = nil
    end

    def run!
      @result = test_framework_runner.run([@test_file])
      self
    end

    def passed?
      raise NotImplementedError
    end

    def test_framework_runner
      raise NotImplementedError
    end
  end

  # Test Runner Subclass for RSpec
  class RSpecRunner < TestRunner
    def passed?
      @result&.zero?
    end

    def test_framework_runner
      RSpec::Core::Runner
    end
  end

  # Test Runner Subclass for Minitest
  class MinitestRunner < TestRunner
    def passed?
      @result
    end

    def test_framework_runner
      Minitest
    end
  end
end