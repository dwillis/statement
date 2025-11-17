# Statement Gem - Maintainer's Guide

## Overview

This guide provides information for maintaining and extending the Statement gem for parsing congressional press releases and statements.

## Version 2.3 Updates

### Major Improvements

1. **Error Handling & Logging**
   - Added comprehensive logging system that doesn't crash on errors
   - All errors are logged with timestamps and severity levels
   - Scrapers return empty arrays instead of crashing on failures
   - Automatic retry logic with exponential backoff for network errors

2. **Command-Line Interface**
   - New `statement` CLI for running scrapers
   - Support for filtering by congress number and type (members/committees)
   - Multiple output formats (JSON, CSV, pretty print)
   - Performance metrics tracking

3. **Testing & Performance Framework**
   - Automated testing suite for all scrapers
   - Performance metrics collection
   - Multiple report formats (text, JSON, CSV, HTML)
   - Identifies slow and broken scrapers

4. **Code Organization**
   - Modular architecture with ScraperBase class
   - Improved maintainability
   - Better separation of concerns

## Architecture

### Key Components

```
lib/statement/
├── logger.rb                 # Logging system
├── scraper_base.rb          # Base class with error handling
├── scraper_registry.rb      # Scraper registry (future use)
├── scraper_tester.rb        # Testing and performance framework
├── scraper.rb               # All scraper implementations (3217 lines)
├── feed.rb                  # RSS feed parsing
├── utils.rb                 # Utility functions
├── facebook.rb              # Facebook integration
├── tweets.rb                # Twitter integration
└── version.rb               # Version number

bin/
├── statement                # CLI for running scrapers
└── test_scrapers           # Testing and performance tool
```

### Scraper Base Class

All scrapers now inherit from `ScraperBase` which provides:

- **open_html(url, retries = 0)**: Fetches and parses HTML with automatic retries
- **safe_scrape(name, &block)**: Wraps scraper execution with error handling
- **parse_date(date_string, format = nil)**: Safe date parsing
- **build_result(...)**: Helper for building result hashes

### Logging

The logging system provides different severity levels:

```ruby
Statement::Logger.debug("Detailed debugging info")
Statement::Logger.info("General information")
Statement::Logger.warn("Warning messages")
Statement::Logger.error("Error messages")
Statement::Logger.fatal("Fatal errors")
```

Configure log level:
```ruby
Statement::Logger.setup(log_level: Logger::INFO, output: $stdout)
```

## Using the CLI

### Basic Usage

```bash
# Run all member scrapers (default: 119th Congress)
statement --type members

# Run all committee scrapers
statement --type committees

# Run everything
statement --type all

# Run a specific scraper
statement --scraper shaheen

# Scrape a single URL
statement --url "https://example.com/rss"

# Save to file with performance metrics
statement --type members --output results.json --performance

# Change output format
statement --type members --format pretty
statement --type members --format csv --output results.csv

# List all available scrapers
statement --list-scrapers

# Adjust logging level
statement --type members --log-level debug
```

## Testing Scrapers

### Running Tests

```bash
# Test all scrapers and generate report
ruby -I lib bin/test_scrapers

# Test only members or committees
ruby -I lib bin/test_scrapers --members
ruby -I lib bin/test_scrapers --committees

# Generate different report formats
ruby -I lib bin/test_scrapers --json --output=report.json
ruby -I lib bin/test_scrapers --csv --output=report.csv
ruby -I lib bin/test_scrapers --html --output=report.html
```

### Interpreting Performance Reports

The performance report shows:

- **Success Rate**: Percentage of working scrapers
- **Response Time**: Average, min, max scraper execution times
- **Error Details**: Specific errors for each failed scraper
- **Recommendations**: Scrapers needing attention

Example output:
```
SUMMARY
Total scrapers tested:         185
Successful:                    145 (78.4%)
Warnings (empty results):      15 (8.1%)
Failed:                        23 (12.4%)
Errors:                        2 (1.1%)
```

## Common Issues

### 403 Forbidden Errors

Many congressional websites now block automated scrapers with 403 errors. This is expected behavior.

**Solutions:**
1. Sites return proper error pages that include reasons
2. The gem now logs these and continues instead of crashing
3. Consider using RSS feeds where available (see `Statement::Feed.from_rss`)
4. Some sites may work with different user agents (already configured in ScraperBase)

### Missing Scrapers

Some members listed in `member_methods` may not have corresponding scraper implementations (e.g., `emmer`, `porter`).

**To add a missing scraper:**

1. Find the member's press release page
2. Determine the page structure (inspect HTML)
3. Add scraper method to `scraper.rb`:

```ruby
def self.member_name(page=1)
  results = []
  url = "https://membername.house.gov/press-releases?page=#{page}"
  doc = open_html(url)
  return [] if doc.nil?

  doc.css('.press-release-item').each do |row|
    results << {
      source: url,
      url: row.at_css('a')['href'],
      title: row.at_css('.title').text.strip,
      date: parse_date(row.at_css('.date').text),
      domain: 'membername.house.gov'
    }
  end

  results
end
```

4. Add to `member_methods` array (line ~40)
5. Add to `member_scrapers` method call list (line ~65)

### Slow Scrapers

Scrapers taking >5 seconds may need optimization:

1. Check if page has pagination (reduce items per page)
2. Verify URL is correct and loads quickly in browser
3. Check if site is blocking/throttling requests
4. Consider caching for frequently accessed pages

### Date Parsing Errors

If dates aren't parsing correctly:

```ruby
# Use specific date format
date = parse_date(date_string, "%m/%d/%Y")

# Or try American date format (already included via american_date gem)
date = Date.parse("12/25/2024") # Works as MM/DD/YYYY
```

## Adding New Scrapers

### Step-by-Step Process

1. **Identify the member/committee**
   - Get their official website
   - Find their press releases page
   - Note if they have an RSS feed

2. **If RSS feed available:**
   ```ruby
   # No need for a custom scraper, use:
   Statement::Feed.from_rss('https://member.gov/rss.xml')
   ```

3. **If custom scraper needed:**

   a. Inspect the HTML structure
   b. Identify patterns (CSS selectors for title, URL, date)
   c. Write the scraper method
   d. Test it
   e. Add to member_methods/committee_methods array

4. **Test the scraper:**
   ```bash
   ruby -I lib -e "require 'statement'; puts Statement::Scraper.new_method.inspect"
   ```

### Scraper Patterns

The gem uses several common patterns for similar website structures:

- **document_query_new**: House members using DocumentQuery.aspx
- **media_body**: Sites with .media-body CSS class
- **article_block**: Sites with .ArticleBlock structure
- **senate_drupal**: Senate sites using Drupal CMS
- **react**: Sites built with React (slower, need JS rendering)

When adding a member, check if they use one of these patterns first.

## Performance Optimization

### Best Practices

1. **Use pagination wisely**: Don't scrape more pages than needed
2. **Implement caching**: For frequently accessed data
3. **Batch operations**: Use `Statement::Feed.batch(urls)` for multiple RSS feeds
4. **Error handling**: Always use the base class methods
5. **Logging**: Use appropriate log levels (INFO for normal, DEBUG for development)

### Monitoring

Run regular performance tests:

```bash
# Weekly performance check
ruby -I lib bin/test_scrapers --output=reports/weekly-$(date +%Y%m%d).txt

# Compare performance over time
diff reports/weekly-20241110.txt reports/weekly-20241117.txt
```

## Output Format

### Standard Result Format

Each scraper returns an array of hashes:

```ruby
[
  {
    source: "https://member.gov/press",     # Source URL
    url: "https://member.gov/press/123",    # Press release URL
    title: "Member Announces New Bill",     # Title
    date: #<Date: 2024-11-17>,             # Date object
    domain: "member.gov"                    # Domain name
  },
  # ... more results
]
```

### Suggested Improvements

Consider adding:

1. **Member metadata**:
   ```ruby
   {
     # ... existing fields ...
     member_name: "John Doe",
     state: "CA",
     district: "12",
     party: "D",
     chamber: "House"
   }
   ```

2. **Content extraction**:
   ```ruby
   {
     # ... existing fields ...
     summary: "First paragraph or excerpt",
     full_text: "Complete press release text",
     topics: ["healthcare", "education"]
   }
   ```

3. **Social media links**:
   ```ruby
   {
     # ... existing fields ...
     twitter_url: "https://twitter.com/member/status/123",
     facebook_url: "https://facebook.com/member/posts/123"
   }
   ```

## Troubleshooting

### Common Problems

**Problem**: "LoadError: cannot load such file"
```bash
# Solution: Run with proper load path
ruby -I lib script.rb
# Or install gem first
bundle install
```

**Problem**: "All scrapers returning nil"
```bash
# Check if sites are accessible
curl -I https://member.gov/press

# Try with user agent
curl -H "User-Agent: Mozilla/5.0" https://member.gov/press
```

**Problem**: "Date parsing errors"
```ruby
# Use american_date gem (already included)
require 'american_date'
Date.parse("11/17/2024") # Works as MM/DD/YYYY
```

## Maintenance Schedule

### Weekly
- Run performance tests
- Check for broken scrapers
- Update any scrapers with website changes

### Monthly
- Review error logs
- Update member list against official House/Senate rosters
- Check for new members needing scrapers

### Quarterly
- Full scraper audit
- Performance optimization review
- Update dependencies

### Annually
- Major version updates
- Architecture review
- Documentation updates

## Current Status (as of 2024-11-17)

Based on the latest performance report:

- **Total scrapers**: 185
- **Working**: 0 (most sites blocking automated access)
- **Need attention**: 185 (mostly due to 403 errors)
- **Missing**: 2 (emmer, porter - not implemented)

### Recommendations

1. **Prioritize RSS feeds**: More reliable than HTML scraping
2. **Focus on high-value members**: Leadership, committee chairs
3. **Partner with congressional offices**: Get official data access
4. **Consider alternate approaches**: APIs, official data feeds

## Contributing

When adding or updating scrapers:

1. Test thoroughly with the test suite
2. Update member_methods/committee_methods arrays
3. Document any special considerations
4. Run performance tests to ensure no degradation
5. Update this guide if adding new patterns

## Resources

- [Official House directory](https://www.house.gov/representatives)
- [Official Senate directory](https://www.senate.gov/senators)
- [ProPublica Congress API](https://projects.propublica.org/api-docs/congress-api/)
- [GovTrack](https://www.govtrack.us/)

## Support

For issues or questions:
1. Check existing GitHub issues
2. Review this guide and documentation
3. Run performance tests to identify specific problems
4. Create new GitHub issue with details

---

**Last Updated**: 2024-11-17
**Version**: 2.3
**Maintainer**: Derek Willis
