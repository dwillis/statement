require 'json'
require 'csv'
require_relative 'logger'

module Statement
  class ScraperTester
    attr_reader :results

    def initialize
      @results = []
    end

    # Test all member scrapers
    def test_members
      Statement::Logger.info("Testing all member scrapers...")
      test_scrapers(Statement::Scraper.member_methods, 'member')
    end

    # Test all committee scrapers
    def test_committees
      Statement::Logger.info("Testing all committee scrapers...")
      test_scrapers(Statement::Scraper.committee_methods, 'committee')
    end

    # Test all scrapers
    def test_all
      test_members
      test_committees
    end

    # Test a single scraper
    def test_scraper(method_name, type = 'unknown')
      Statement::Logger.info("Testing #{method_name}...")

      result = {
        scraper: method_name,
        type: type,
        status: 'pending',
        error: nil,
        duration: 0,
        result_count: 0,
        sample_result: nil,
        tested_at: Time.now
      }

      start_time = Time.now

      begin
        data = Statement::Scraper.send(method_name)
        result[:duration] = Time.now - start_time

        if data.nil?
          result[:status] = 'failed'
          result[:error] = 'Returned nil'
          result[:result_count] = 0
        elsif !data.is_a?(Array)
          # Some scrapers might return a single hash
          result[:status] = 'success'
          result[:result_count] = 1
          result[:sample_result] = data
        elsif data.empty?
          result[:status] = 'warning'
          result[:error] = 'No results returned'
          result[:result_count] = 0
        else
          result[:status] = 'success'
          result[:result_count] = data.length
          result[:sample_result] = data.first
        end

        Statement::Logger.info("✓ #{method_name}: #{result[:status]} (#{result[:result_count]} results in #{result[:duration].round(2)}s)")
      rescue StandardError => e
        result[:duration] = Time.now - start_time
        result[:status] = 'error'
        result[:error] = "#{e.class}: #{e.message}"
        Statement::Logger.error("✗ #{method_name}: #{e.class} - #{e.message}")
      end

      @results << result
      result
    end

    # Test scrapers with pagination
    def test_with_pagination(method_name, pages = 3)
      Statement::Logger.info("Testing #{method_name} with pagination (#{pages} pages)...")

      results = []
      total_duration = 0
      errors = []

      (1..pages).each do |page|
        begin
          start_time = Time.now
          data = Statement::Scraper.send(method_name, page: page)
          duration = Time.now - start_time
          total_duration += duration

          if data.nil? || (data.is_a?(Array) && data.empty?)
            Statement::Logger.warn("Page #{page}: No results")
            break
          else
            count = data.is_a?(Array) ? data.length : 1
            results << { page: page, count: count, duration: duration }
            Statement::Logger.info("Page #{page}: #{count} results in #{duration.round(2)}s")
          end
        rescue StandardError => e
          errors << { page: page, error: "#{e.class}: #{e.message}" }
          Statement::Logger.error("Page #{page}: #{e.class} - #{e.message}")
        end
      end

      {
        scraper: method_name,
        pages_tested: pages,
        pages_succeeded: results.length,
        total_results: results.sum { |r| r[:count] },
        total_duration: total_duration,
        errors: errors,
        page_details: results
      }
    end

    # Generate a performance report
    def generate_report(format: 'text', output: nil)
      case format
      when 'json'
        report = generate_json_report
      when 'csv'
        report = generate_csv_report
      when 'html'
        report = generate_html_report
      else
        report = generate_text_report
      end

      if output
        File.write(output, report)
        Statement::Logger.info("Report written to #{output}")
      else
        puts report
      end

      report
    end

    private

    def test_scrapers(methods, type)
      methods.each do |method|
        test_scraper(method, type)
      end
    end

    def generate_text_report
      report = []
      report << "=" * 100
      report << "STATEMENT SCRAPER PERFORMANCE REPORT"
      report << "Generated: #{Time.now}"
      report << "=" * 100
      report << ""

      # Summary statistics
      total = @results.length
      successful = @results.count { |r| r[:status] == 'success' }
      warnings = @results.count { |r| r[:status] == 'warning' }
      failed = @results.count { |r| r[:status] == 'failed' }
      errors = @results.count { |r| r[:status] == 'error' }

      report << "SUMMARY"
      report << "-" * 100
      report << sprintf("%-30s %s", "Total scrapers tested:", total)
      report << sprintf("%-30s %s (%.1f%%)", "Successful:", successful, (successful.to_f / total * 100))
      report << sprintf("%-30s %s (%.1f%%)", "Warnings (empty results):", warnings, (warnings.to_f / total * 100))
      report << sprintf("%-30s %s (%.1f%%)", "Failed:", failed, (failed.to_f / total * 100))
      report << sprintf("%-30s %s (%.1f%%)", "Errors:", errors, (errors.to_f / total * 100))
      report << ""

      # Performance statistics
      durations = @results.map { |r| r[:duration] }
      avg_duration = durations.sum / durations.length
      max_duration = durations.max
      min_duration = durations.min

      report << "PERFORMANCE"
      report << "-" * 100
      report << sprintf("%-30s %.2fs", "Average scraper time:", avg_duration)
      report << sprintf("%-30s %.2fs", "Fastest scraper:", min_duration)
      report << sprintf("%-30s %.2fs", "Slowest scraper:", max_duration)
      report << sprintf("%-30s %.2fs", "Total time:", durations.sum)
      report << ""

      # Results by type
      member_results = @results.select { |r| r[:type] == 'member' }
      committee_results = @results.select { |r| r[:type] == 'committee' }

      if member_results.any?
        report << "MEMBER SCRAPERS (#{member_results.length} total)"
        report << "-" * 100
        report += format_results_section(member_results)
        report << ""
      end

      if committee_results.any?
        report << "COMMITTEE SCRAPERS (#{committee_results.length} total)"
        report << "-" * 100
        report += format_results_section(committee_results)
        report << ""
      end

      # Detailed results
      report << "DETAILED RESULTS"
      report << "-" * 100
      report << sprintf("%-40s %-10s %-15s %-10s %s", "Scraper", "Status", "Duration", "Results", "Error")
      report << "-" * 100

      @results.sort_by { |r| r[:status] == 'success' ? 0 : 1 }.each do |result|
        status_icon = case result[:status]
                      when 'success' then '✓'
                      when 'warning' then '⚠'
                      when 'failed' then '✗'
                      when 'error' then '✗✗'
                      else '?'
                      end

        error_msg = result[:error] ? result[:error][0..40] : ''
        report << sprintf("%-40s %-10s %-15s %-10s %s",
                          result[:scraper],
                          "#{status_icon} #{result[:status]}",
                          "#{result[:duration].round(2)}s",
                          result[:result_count],
                          error_msg)
      end

      report << ""
      report << "RECOMMENDATIONS"
      report << "-" * 100

      # Find problem scrapers
      problem_scrapers = @results.select { |r| r[:status] != 'success' }
      if problem_scrapers.any?
        report << ""
        report << "Scrapers needing attention (#{problem_scrapers.length}):"
        problem_scrapers.each do |result|
          report << "  - #{result[:scraper]}: #{result[:error]}"
        end
      else
        report << "All scrapers are working correctly!"
      end

      # Find slow scrapers
      slow_scrapers = @results.select { |r| r[:duration] > 5 }.sort_by { |r| -r[:duration] }
      if slow_scrapers.any?
        report << ""
        report << "Slow scrapers (>5s) - consider optimization (#{slow_scrapers.length}):"
        slow_scrapers.first(10).each do |result|
          report << "  - #{result[:scraper]}: #{result[:duration].round(2)}s"
        end
      end

      report << ""
      report << "=" * 100

      report.join("\n")
    end

    def format_results_section(results)
      output = []
      successful = results.count { |r| r[:status] == 'success' }
      output << sprintf("  Successful: %d (%.1f%%)", successful, (successful.to_f / results.length * 100))
      output << sprintf("  Total results collected: %d", results.sum { |r| r[:result_count] })
      output << sprintf("  Average time: %.2fs", results.sum { |r| r[:duration] } / results.length)
      output
    end

    def generate_json_report
      report = {
        generated_at: Time.now,
        summary: {
          total: @results.length,
          successful: @results.count { |r| r[:status] == 'success' },
          warnings: @results.count { |r| r[:status] == 'warning' },
          failed: @results.count { |r| r[:status] == 'failed' },
          errors: @results.count { |r| r[:status] == 'error' }
        },
        performance: {
          total_duration: @results.sum { |r| r[:duration] },
          average_duration: @results.sum { |r| r[:duration] } / @results.length,
          min_duration: @results.map { |r| r[:duration] }.min,
          max_duration: @results.map { |r| r[:duration] }.max
        },
        results: @results
      }

      JSON.pretty_generate(report)
    end

    def generate_csv_report
      CSV.generate do |csv|
        csv << ['Scraper', 'Type', 'Status', 'Duration (s)', 'Result Count', 'Error', 'Tested At']
        @results.each do |result|
          csv << [
            result[:scraper],
            result[:type],
            result[:status],
            result[:duration].round(2),
            result[:result_count],
            result[:error] || '',
            result[:tested_at]
          ]
        end
      end
    end

    def generate_html_report
      html = <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <title>Statement Scraper Performance Report</title>
          <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            h1 { color: #333; }
            table { border-collapse: collapse; width: 100%; margin: 20px 0; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background-color: #4CAF50; color: white; }
            tr:nth-child(even) { background-color: #f2f2f2; }
            .success { color: green; }
            .warning { color: orange; }
            .failed, .error { color: red; }
            .summary { background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0; }
          </style>
        </head>
        <body>
          <h1>Statement Scraper Performance Report</h1>
          <p>Generated: #{Time.now}</p>

          <div class="summary">
            <h2>Summary</h2>
            <p>Total scrapers tested: #{@results.length}</p>
            <p class="success">Successful: #{@results.count { |r| r[:status] == 'success' }} (#{(@results.count { |r| r[:status] == 'success' }.to_f / @results.length * 100).round(1)}%)</p>
            <p class="warning">Warnings: #{@results.count { |r| r[:status] == 'warning' }}</p>
            <p class="failed">Failed: #{@results.count { |r| r[:status] == 'failed' }}</p>
            <p class="error">Errors: #{@results.count { |r| r[:status] == 'error' }}</p>
          </div>

          <h2>Detailed Results</h2>
          <table>
            <thead>
              <tr>
                <th>Scraper</th>
                <th>Type</th>
                <th>Status</th>
                <th>Duration (s)</th>
                <th>Results</th>
                <th>Error</th>
              </tr>
            </thead>
            <tbody>
      HTML

      @results.each do |result|
        html += <<~ROW
              <tr class="#{result[:status]}">
                <td>#{result[:scraper]}</td>
                <td>#{result[:type]}</td>
                <td>#{result[:status]}</td>
                <td>#{result[:duration].round(2)}</td>
                <td>#{result[:result_count]}</td>
                <td>#{result[:error] || ''}</td>
              </tr>
        ROW
      end

      html += <<~HTML
            </tbody>
          </table>
        </body>
        </html>
      HTML

      html
    end
  end
end
