# frozen_string_literal: true

# test_coverage reporter for Solargraph
module SolargraphTestCoverage
  class TestCoverageReporter < Solargraph::Diagnostics::Base
    include Helpers

    #
    # LSP Diagnostic method
    #
    # @return [Array]
    #
    def diagnose(source, _api_map)
      return [] if source.code.empty? || !source.location.filename.include?('/app/')

      test_file = locate_test_file(source)
      return [] unless File.file?(test_file)

      results  = run_rspec(source, test_file)
      lines    = uncovered_lines(results).map { |line| line_coverage_warning(source, line) }
      branches = uncovered_branches(results).map { |branch| branch_coverage_warning(source, branch.report) }

      lines + branches
    rescue ChildFailedError
      []
    end

    private

    #
    # Creates LSP warning message for missing line coverage
    #
    # @return [Hash]
    #
    def line_coverage_warning(source, line)
      {
        range: Solargraph::Range.from_to(line, 0, line, source.code.lines[line].length).to_hash,
        severity: Solargraph::Diagnostics::Severities::WARNING,
        source: 'TestCoverage',
        message: 'Line is missing test coverage'
      }
    end

    #
    # Creates LSP warning message for missing branch coverage
    #
    # @return [Hash]
    #
    def branch_coverage_warning(source, report)
      {
        range: Solargraph::Range.from_to(report[:line], 0, report[:line], source.code.lines[report[:line]].length).to_hash,
        severity: Solargraph::Diagnostics::Severities::WARNING,
        source: 'TestCoverage',
        message: "'#{report[:type].upcase}' branch is missing test coverage"
      }
    end
  end
end
