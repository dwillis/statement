# encoding: utf-8
require 'uri'
require 'open-uri'
require 'american_date'
require 'nokogiri'
require 'timeout'
require_relative 'logger'

module Statement
  class ScraperBase
    TIMEOUT = 30 # seconds
    MAX_RETRIES = 2

    class << self
      # Open and parse HTML with error handling and retries
      def open_html(url, retries = 0)
        Timeout.timeout(TIMEOUT) do
          # Add user agent header to avoid 403 errors
          options = {
            'User-Agent' => 'Mozilla/5.0 (compatible; StatementGem/2.3; +https://github.com/dwillis/statement)',
            'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language' => 'en-US,en;q=0.5'
          }
          doc = Nokogiri::HTML(URI.open(url, options).read)
          Statement::Logger.debug("Successfully fetched #{url}")
          doc
        end
      rescue Timeout::Error => e
        Statement::Logger.error("Timeout fetching #{url}: #{e.message}")
        retry_or_return(url, retries)
      rescue OpenURI::HTTPError => e
        Statement::Logger.error("HTTP error fetching #{url}: #{e.message}")
        retry_or_return(url, retries)
      rescue SocketError => e
        Statement::Logger.error("Socket error fetching #{url}: #{e.message}")
        retry_or_return(url, retries)
      rescue StandardError => e
        Statement::Logger.error("Error fetching #{url}: #{e.class} - #{e.message}")
        Statement::Logger.debug(e.backtrace.join("\n"))
        nil
      end

      def retry_or_return(url, retries)
        if retries < MAX_RETRIES
          Statement::Logger.info("Retrying #{url} (attempt #{retries + 1}/#{MAX_RETRIES})")
          sleep(2 ** retries) # Exponential backoff
          open_html(url, retries + 1)
        else
          Statement::Logger.error("Failed to fetch #{url} after #{MAX_RETRIES} retries")
          nil
        end
      end

      # Safe scraper execution wrapper
      def safe_scrape(scraper_name, &block)
        Statement::Logger.info("Starting scraper: #{scraper_name}")
        start_time = Time.now

        begin
          results = yield
          duration = Time.now - start_time

          if results.nil?
            Statement::Logger.warn("#{scraper_name} returned nil")
            return []
          end

          results = [results] unless results.is_a?(Array)
          Statement::Logger.info("#{scraper_name} completed in #{duration.round(2)}s, found #{results.length} results")
          results
        rescue StandardError => e
          duration = Time.now - start_time
          Statement::Logger.error("#{scraper_name} failed after #{duration.round(2)}s: #{e.class} - #{e.message}")
          Statement::Logger.debug(e.backtrace.join("\n"))
          [] # Return empty array instead of crashing
        end
      end

      # Parse date with error handling
      def parse_date(date_string, format = nil)
        return nil if date_string.nil? || date_string.strip.empty?

        if format
          Date.strptime(date_string.strip, format)
        else
          Date.parse(date_string.strip)
        end
      rescue ArgumentError, TypeError => e
        Statement::Logger.warn("Could not parse date '#{date_string}': #{e.message}")
        nil
      end

      # Build result hash
      def build_result(url:, source:, title:, date:, domain:, **options)
        {
          source: source,
          url: url,
          title: title&.strip,
          date: date,
          domain: domain
        }.merge(options)
      end

      def current_year
        Date.today.year
      end

      def current_month
        Date.today.month
      end
    end
  end
end
