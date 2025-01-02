# encoding: utf-8
require 'uri'
require 'open-uri'
require 'american_date'
require 'nokogiri'

module Statement
  class Scraper

    def self.open_html(url)
      begin
        Nokogiri::HTML(open(url).read)
      rescue
        nil
      end
    end

    def self.house_gop(url)
      doc = open_html(url)
      return unless doc
      uri = URI.parse(url)
      date = Date.parse(uri.query.split('=').last)
      links = doc.xpath("//ul[@id='membernews']").search('a')
      results = links.map do |link|
        abs_link = Utils.absolute_link(url, link["href"])
        { :source => url, :url => abs_link, :title => link.text.strip, :date => date, :domain => URI.parse(link["href"]).host }
      end
      Utils.remove_generic_urls!(results)
    end

    def self.current_year
      Date.today.year
    end

    def self.current_month
      Date.today.month
    end

    def self.member_methods
      [:klobuchar, :crapo, :trentkelly, :kilmer, :cardin, :heinrich, :bucshon, :document_query_new, :costa, :jordan, :barr, :lamborn, :media_body, :trone, :spanberger,
      :wenstrup, :robbishop, :manchin, :timscott, :senate_drupal_newscontent, :shaheen, :paul, :tlaib, :grijalva, :aguilar, :bergman, :scanlon, :gimenez, :mcgovern,
      :inhofe, :document_query, :fischer, :clark, :schiff, :barbaralee, :cantwell, :wyden, :cornyn, :connolly, :mast, :hassan, :vandrew, :rickscott, :joyce, :gosar, :article_block_h2,
      :schumer, :cassidy, :mcmorris, :takano, :gillibrand, :garypeters, :webster, :cortezmasto, :hydesmith, :senate_wordpress, :recordlist, :rosen, :schweikert, :article_block_h2_date,
      :grassley, :bennet, :drupal, :durbin, :senate_drupal, :senate_drupal_new, :rounds, :sullivan, :kennedy, :duckworth, :angusking, :tillis, :emmer, :house_title_header, :good, :lujan,
      :porter, :jasonsmith, :moulton, :bacon, :capito, :tonko, :larsen, :mooney, :ellzey, :media_digest, :crawford, :lucas, :article_newsblocker, :pressley, :reschenthaler, :hoyer,
      :cartwright, :article_block, :jackreed, :blackburn, :article_block_h1, :casey, :schatz, :kaine, :cruz, :padilla, :baldwin, :clyburn, :titus, :houlahan, :react]
    end

    def self.committee_methods
      [:senate_approps_majority, :senate_approps_minority, :senate_banking_majority, :senate_banking_minority, :senate_hsag_majority, :senate_hsag_minority,
      :senate_indian_republican, :senate_indian_democratic, :senate_ag_majority, :senate_ag_minority, :senate_budget_majority, :senate_budget_minority,
      :senate_commerce_majority, :senate_commerce_minority, :senate_epw_majority, :senate_epw_minority, :senate_finance_majority, :senate_finance_minority,
      :senate_foreign_relations_majority, :senate_foreign_relations_minority, :senate_help_majority, :senate_help_minority, :senate_judiciary_majority,
      :senate_judiciary_minority, :senate_rules_majority, :senate_rules_minority, :senate_smallbiz_majority, :senate_smallbiz_minority, :senate_intel,
      :house_ag_majority, :house_ag_minority, :house_approps_minority, :house_armedservices_majority, :house_armedservices_minority, :house_education_majority,
      :house_energy_majority, :house_ethics, :house_financial_services_majority, :house_financial_services_minority, :house_foreign_affairs_majority,
      :house_homeland_security_majority, :house_administration_majority, :house_administration_minority, :house_judiciary_minority, :house_resources_majority,
      :house_science_majority, :house_science_minority, :house_smallbiz_majority, :house_smallbiz_minority, :house_transportation_majority, :house_transportation_minority,
      :house_veterans_minority, :house_intel_majority, :house_intel_minority, :house_climate_majority, :house_modernization]
    end

    def self.member_scrapers
      year = Date.today.year
      results = [klobuchar(year), kilmer, sullivan, shaheen, timscott, wenstrup, bucshon, angusking, document_query_new, jordan, lamborn, senate_wordpress, media_body, scanlon,
        document_query([], page=1), document_query([], page=2), crapo, grassley(page=1), baldwin, casey, cruz, schatz, cassidy, cantwell, cornyn, senate_drupal_new, tlaib,
        inhofe, fischer, kaine, padilla, clark, trentkelly, barbaralee, cardin, wyden, webster, mast, hassan, cortezmasto, manchin, costa, react,
        schumer, mcmorris, takano, heinrich, garypeters, rounds, connolly, paul, hydesmith, rickscott, mooney, ellzey, bergman, gimenez, article_block_h2, hoyer,
        bennet(page=1), drupal, durbin(page=1), gillibrand, kennedy, duckworth, senate_drupal_newscontent, senate_drupal, vandrew, tillis, barr, porter, crawford, good, lujan,
        jasonsmith, moulton, bacon, capito, house_title_header, recordlist, tonko, aguilar, rosen, spanberger, media_digest, pressley, reschenthaler, article_block_h2_date,
        larsen, grijalva, cartwright, article_block, jackreed, blackburn, article_block_h1, clyburn, titus, trone, joyce, houlahan, lucas, schweikert, gosar, mcgovern].flatten
      results = results.compact
      Utils.remove_generic_urls!(results)
    end

    def self.backfill_from_scrapers
      results = [document_query(page=3), cardin(page=2), cornyn(page=1), timscott(page=2), timscott(page=3), document_query(page=4), grassley(page=2), grassley(page=3), grassley(page=4), cantwell(page=2),
        clark(year=2013), kilmer(page=2), kilmer(page=3), heinrich(page=2), manchin(page=2), manchin(page=3),
        cassidy(page=2), cassidy(page=3), gillibrand(page=2), paul(page=1), paul(page=2), olson(year=2013), schumer(page=2), schumer(page=3), poe(year=2015, month=2), wyden(page=2),
        schiff(page=2), schiff(page=3), takano(page=2), takano(page=3)].flatten
      Utils.remove_generic_urls!(results)
    end

    def self.committee_scrapers
      results = [senate_approps_majority, senate_approps_minority, senate_banking_majority, senate_banking_minority, senate_hsag_majority, senate_hsag_minority,
      senate_indian_republican, senate_indian_democratic, senate_ag_majority, senate_ag_minority, senate_budget_majority, senate_budget_minority,
      senate_commerce_majority, senate_commerce_minority, senate_epw_majority, senate_epw_minority, senate_finance_majority, senate_finance_minority,
      senate_foreign_relations_majority, senate_foreign_relations_minority, senate_help_majority, senate_help_minority, senate_judiciary_majority,
      senate_judiciary_minority, senate_rules_majority, senate_rules_minority, senate_smallbiz_majority, senate_smallbiz_minority, senate_intel,
      house_ag_majority, house_ag_minority, house_approps_minority, house_armedservices_majority, house_armedservices_minority, house_education_majority,
      house_energy_majority, house_ethics, house_financial_services_majority, house_financial_services_minority, house_foreign_affairs_majority,
      house_homeland_security_majority, house_administration_majority, house_administration_minority, house_judiciary_minority, house_resources_majority,
      house_science_majority, house_science_minority, house_smallbiz_majority, house_smallbiz_minority, house_transportation_majority, house_transportation_minority,
      house_veterans_minority, house_intel_majority, house_intel_minority, house_climate_majority, house_modernization].flatten
      Utils.remove_generic_urls!(results)
    end

    ## special cases for committees without RSS feeds

    def self.senate_approps_majority(page=1)
      results = []
      url = "https://www.appropriations.senate.gov/news/majority?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          title = row.text.strip
          release_url = "https://www.appropriations.senate.gov" + row.css('a').first['href'].strip
          raw_date = row.previous.previous.text
          date = begin Date.strptime(raw_date, "%m.%d.%y") rescue nil end
          results << { :source => url,
                       :url => release_url,
                       :title => title,
                       :date => date,
                       :domain => 'www.appropriations.senate.gov',
                       :party => "majority" }
      end
      results
    end

    def self.senate_approps_minority(page=1)
      results = []
      url = "https://www.appropriations.senate.gov/news/minority?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          title = row.text.strip
          release_url = "https://www.appropriations.senate.gov" + row.css('a').first['href'].strip
          raw_date = row.previous.previous.text
          date = begin Date.strptime(raw_date, "%m.%d.%y") rescue nil end
          results << { :source => url,
                       :url => release_url,
                       :title => title,
                       :date => date,
                       :domain => 'www.appropriations.senate.gov',
                       :party => "minority" }
      end
      results
    end

    def self.senate_banking_majority(page=1)
      results = []
      url = "https://www.banking.senate.gov/newsroom/majority-press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#browser_table tr").each do |row|
        next if row.attributes['class']&.value == 'divider'
        title = row.children[3].text.strip
        release_url = row.children[3].css('a')[0]['href'].strip
        raw_date = row.children[1].text.strip
        date = begin Date.strptime(raw_date, "%m/%d/%y") rescue nil end
        results << { :source => url,
                     :url => release_url,
                     :title => title,
                     :date => date,
                     :domain => 'www.banking.senate.gov',
                     :party => "majority" }
      end
      results
    end

    def self.senate_banking_minority(page=1)
      results = []
      url = "https://www.banking.senate.gov/newsroom/minority-press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#browser_table tr").each do |row|
        next if row.attributes['class']&.value == 'divider'
        title = row.children[3].text.strip
        release_url = row.children[3].css('a')[0]['href'].strip
        raw_date = row.children[1].text.strip
        date = begin Date.strptime(raw_date, "%m/%d/%y") rescue nil end
        results << { :source => url,
                     :url => release_url,
                     :title => title,
                     :date => date,
                     :domain => 'www.banking.senate.gov',
                     :party => "minority" }
      end
      results
    end

    def self.senate_hsag_majority(page=1)
      results = []
      url = "https://www.hsgac.senate.gov/media/majority-media?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#listing tr").each do |row|
        next if row.attributes['class']&.value == 'divider'
        title = row.children[3].text.strip
        release_url = row.children[3].css('a')[0]['href'].strip
        raw_date = row.children[1].text.strip
        date = begin Date.strptime(raw_date, "%m/%d/%y") rescue nil end
        results << { :source => url,
                     :url => release_url.gsub("http:","https:"),
                     :title => title,
                     :date => date,
                     :domain => 'www.hsgac.senate.gov',
                     :party => "majority" }
      end
      results
    end

    def self.senate_hsag_minority(page=1)
      results = []
      url = "https://www.hsgac.senate.gov/media/minority-media?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#listing tr").each do |row|
        next if row.attributes['class']&.value == 'divider'
        title = row.children[3].text.strip
        release_url = row.children[3].css('a')[0]['href'].strip
        raw_date = row.children[1].text.strip
        date = begin Date.strptime(raw_date, "%m/%d/%y") rescue nil end
        results << { :source => url,
                     :url => release_url.gsub("http:","https:"),
                     :title => title,
                     :date => date,
                     :domain => 'www.hsgac.senate.gov',
                     :party => "minority" }
      end
      results
    end

    def self.senate_indian_republican(page=0)
      results = []
      url = "https://www.indian.senate.gov/newsroom/republican-news?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='col-md-12']")[1..-1].each do |row|
        results << { :source => url, :url => "https://www.indian.senate.gov" + row.css('a').first['href'], :title => row.css("h4").text.strip, :date => Date.parse(row.css('.date-display-single')[0].attributes['content'].value), :domain => "www.indian.senate.gov", :party => 'majority' }
      end
      results
    end

    def self.senate_indian_democratic(page=0)
      results = []
      url = "https://www.indian.senate.gov/newsroom/democratic-news?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='col-md-12']")[1..-1].each do |row|
        results << { :source => url, :url => "https://www.indian.senate.gov" + row.css('a').first['href'], :title => row.css("h4").text.strip, :date => Date.parse(row.css('.date-display-single')[0].attributes['content'].value), :domain => "www.indian.senate.gov", :party => 'minority' }
      end
      results
    end

    def self.senate_ag_majority(page=1)
      results = []
      url = "https://www.agriculture.senate.gov/newsroom/majority-news?PageNum_rs=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          title = row.text.strip
          release_url = "https://www.agriculture.senate.gov" + row.css('a').first['href'].strip
          raw_date = row.previous.previous.text
          date = begin Date.strptime(raw_date, "%m.%d.%y") rescue nil end
          results << { :source => url,
                       :url => release_url,
                       :title => title,
                       :date => date,
                       :domain => 'www.agriculture.senate.gov',
                       :party => "majority" }
      end
      results
    end

    def self.senate_ag_minority(page=1)
      results = []
      url = "https://www.agriculture.senate.gov/newsroom/minority-news?PageNum_rs=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          title = row.text.strip
          release_url = "https://www.agriculture.senate.gov" + row.css('a').first['href'].strip
          raw_date = row.previous.previous.text
          date = begin Date.strptime(raw_date, "%m.%d.%y") rescue nil end
          results << { :source => url,
                       :url => release_url,
                       :title => title,
                       :date => date,
                       :domain => 'www.agriculture.senate.gov',
                       :party => "minority" }
      end
      results
    end

    def self.senate_budget_majority(page=1)
      results = []
      url = "https://www.budget.senate.gov/chairman/newsroom/press?PageNum_rs=#{page}&type=press_release"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          title = row.text.strip
          release_url = "https://www.budget.senate.gov" + row.css('a').first['href'].strip
          raw_date = row.previous.previous.text
          date = begin Date.strptime(raw_date, "%m.%d.%y") rescue nil end
          results << { :source => url,
                       :url => release_url,
                       :title => title,
                       :date => date,
                       :domain => 'www.budget.senate.gov',
                       :party => "majority" }
      end
      results
    end

    def self.senate_budget_minority(page=1)
      results = []
      url = "https://www.budget.senate.gov/ranking-member/newsroom/press?PageNum_rs=#{page}&type=press_release"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          title = row.text.strip
          release_url = "https://www.budget.senate.gov" + row.css('a').first['href'].strip
          raw_date = row.previous.previous.text
          date = begin Date.strptime(raw_date, "%m.%d.%y") rescue nil end
          results << { :source => url,
                       :url => release_url,
                       :title => title,
                       :date => date,
                       :domain => 'www.budget.senate.gov',
                       :party => "minority" }
      end
      results
    end

    def self.senate_commerce_majority(year=Date.today.year)
      results = []
      url = "https://www.commerce.senate.gov/public/index.cfm/pressreleases?MonthDisplay=0&YearDisplay=#{year}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      return if doc.xpath("//table[@class='table recordList']").css('tbody tr').empty?
      doc.xpath("//table[@class='table recordList']").css('tbody tr').each do |row|
        title = row.css('td')[1].text.strip
        release_url = "https://www.commerce.senate.gov" + row.css('a').first['href'].strip
        raw_date = row.css('td').first.text
        date = begin Date.strptime(raw_date, "%m/%d/%y") rescue nil end
        results << { :source => url,
                     :url => release_url,
                     :title => title,
                     :date => date,
                     :domain => 'www.commerce.senate.gov',
                     :party => "majority" }
      end
      results
    end

    def self.senate_commerce_minority(year=Date.today.year)
      results = []
      url = "https://www.commerce.senate.gov/public/index.cfm/minority-dems-press-releases?MonthDisplay=0&YearDisplay=#{year}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      return if doc.xpath("//table[@class='table recordList']").css('tbody tr').empty?
      doc.xpath("//table[@class='table recordList']").css('tbody tr').each do |row|
        title = row.css('td')[1].text.strip
        release_url = "https://www.commerce.senate.gov" + row.css('a').first['href'].strip
        raw_date = row.css('td').first.text
        date = begin Date.strptime(raw_date, "%m/%d/%y") rescue nil end
        results << { :source => url,
                     :url => release_url,
                     :title => title,
                     :date => date,
                     :domain => 'www.commerce.senate.gov',
                     :party => "minority" }
      end
      results
    end

    def self.senate_epw_majority(year=Date.today.year)
      results = []
      url = "https://www.epw.senate.gov/public/index.cfm/news?MonthDisplay=0&YearDisplay=#{year}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      return if doc.xpath("//table[@class='table recordList']").css('tbody tr').empty?
      doc.xpath("//table[@class='table recordList']").css('tbody tr').each do |row|
        title = row.css('td')[1].text.strip
        release_url = "https://www.epw.senate.gov" + row.css('a').first['href'].strip
        raw_date = row.css('td').first.text
        date = begin Date.strptime(raw_date, "%m/%d/%y") rescue nil end
        results << { :source => url,
                     :url => release_url,
                     :title => title,
                     :date => date,
                     :domain => 'www.epw.senate.gov',
                     :party => "majority" }
      end
      results
    end

    def self.senate_epw_minority(year=Date.today.year)
      results = []
      url = "https://www.epw.senate.gov/public/index.cfm/press-releases-democratic?MonthDisplay=0&YearDisplay=#{year}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      return if doc.xpath("//table[@class='table recordList']").css('tbody tr').empty?
      doc.xpath("//table[@class='table recordList']").css('tbody tr').each do |row|
        title = row.css('td')[1].text.strip
        release_url = "https://www.epw.senate.gov" + row.css('a').first['href'].strip
        raw_date = row.css('td').first.text
        date = begin Date.strptime(raw_date, "%m/%d/%y") rescue nil end
        results << { :source => url,
                     :url => release_url,
                     :title => title,
                     :date => date,
                     :domain => 'www.epw.senate.gov',
                     :party => "minority" }
      end
      results
    end

    def self.senate_finance_majority(page=1)
      results = []
      url = "https://www.finance.senate.gov/chairmans-news?PageNum_rs=#{page}&type=press_release"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#browser_table tr").each do |row|
        next if row.attributes['class']&.value == 'divider'
        title = row.children[3].text.strip
        release_url = row.children[3].css('a')[0]['href'].strip
        raw_date = row.children[1].text.strip
        date = begin Date.strptime(raw_date, "%m/%d/%y") rescue nil end
        results << { :source => url,
                     :url => release_url,
                     :title => title,
                     :date => date,
                     :domain => 'www.finance.senate.gov',
                     :party => "majority" }
      end
      results
    end

    def self.senate_finance_minority(page=1)
      results = []
      url = "https://www.finance.senate.gov/ranking-members-news?PageNum_rs=#{page}&type=press_release"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#browser_table tr").each do |row|
        next if row.attributes['class']&.value == 'divider'
        title = row.children[3].text.strip
        release_url = row.children[3].css('a')[0]['href'].strip
        raw_date = row.children[1].text.strip
        date = begin Date.strptime(raw_date, "%m/%d/%y") rescue nil end
        results << { :source => url,
                     :url => release_url,
                     :title => title,
                     :date => date,
                     :domain => 'www.finance.senate.gov',
                     :party => "minority" }
      end
      results
    end

    def self.senate_foreign_relations_majority(page=1)
      results = []
      url = "https://www.foreign.senate.gov/press/chair?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#browser_table tr").each do |row|
        next if row.attributes['class']&.value == 'divider'
        title = row.children[1].text.strip
        release_url = row.children[1].css('a')[0]['href'].strip
        raw_date = row.children[3].text.strip
        date = begin Date.strptime(raw_date, "%m/%d/%y") rescue nil end
        results << { :source => url,
                     :url => release_url,
                     :title => title,
                     :date => date,
                     :domain => 'www.foreign.senate.gov',
                     :party => "majority" }
      end
      results
    end

    def self.senate_foreign_relations_minority(page=1)
      results = []
      url = "https://www.foreign.senate.gov/press/ranking?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#browser_table tr").each do |row|
        next if row.attributes['class']&.value == 'divider'
        title = row.children[1].text.strip
        release_url = row.children[1].css('a')[0]['href'].strip
        raw_date = row.children[3].text.strip
        date = begin Date.strptime(raw_date, "%m/%d/%y") rescue nil end
        results << { :source => url,
                     :url => release_url,
                     :title => title,
                     :date => date,
                     :domain => 'www.foreign.senate.gov',
                     :party => "minority" }
      end
      results
    end

    def self.senate_help_majority(page=1)
      results = []
      url = "https://www.help.senate.gov/chair/newsroom/press?PageNum_rs=#{page}&type=press_release"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          title = row.text.strip
          release_url = "https://www.help.senate.gov" + row.css('a').first['href'].strip
          raw_date = row.previous.previous.text
          date = begin Date.strptime(raw_date, "%m.%d.%y") rescue nil end
          results << { :source => url,
                       :url => release_url,
                       :title => title,
                       :date => date,
                       :domain => 'www.help.senate.gov',
                       :party => "majority" }
      end
      results
    end

    def self.senate_help_minority(page=1)
      results = []
      url = "https://www.help.senate.gov/ranking/newsroom/press?PageNum_rs=#{page}&type=press_release"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          title = row.text.strip
          release_url = "https://www.help.senate.gov" + row.css('a').first['href'].strip
          raw_date = row.previous.previous.text
          date = begin Date.strptime(raw_date, "%m.%d.%y") rescue nil end
          results << { :source => url,
                       :url => release_url,
                       :title => title,
                       :date => date,
                       :domain => 'www.help.senate.gov',
                       :party => "minority" }
      end
      results
    end

    def self.senate_judiciary_majority(page=1)
      results = []
      url = "https://www.judiciary.senate.gov/press/majority?PageNum_rs=#{page}&type=press_release"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#browser_table tr").each do |row|
        next if row.attributes['class']&.value == 'divider'
        title = row.children[3].text.strip
        release_url = row.children[3].css('a')[0]['href'].strip
        raw_date = row.children[1].text.strip
        date = begin Date.strptime(raw_date, "%m/%d/%y") rescue nil end
        results << { :source => url,
                     :url => release_url,
                     :title => title,
                     :date => date,
                     :domain => 'www.judiciary.senate.gov',
                     :party => "majority" }
      end
      results
    end

    def self.senate_judiciary_minority(page=1)
      results = []
      url = "https://www.judiciary.senate.gov/press/minority-press?PageNum_rs=#{page}&type=press_release"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#browser_table tr").each do |row|
        next if row.attributes['class']&.value == 'divider'
        title = row.children[3].text.strip
        release_url = row.children[3].css('a')[0]['href'].strip
        raw_date = row.children[1].text.strip
        date = begin Date.strptime(raw_date, "%m/%d/%y") rescue nil end
        results << { :source => url,
                     :url => release_url,
                     :title => title,
                     :date => date,
                     :domain => 'www.judiciary.senate.gov',
                     :party => "minority" }
      end
      results
    end

    def self.senate_rules_majority(page=1)
      results = []
      url = "https://www.rules.senate.gov/news/majority-news"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          title = row.text.strip
          release_url = "https://www.rules.senate.gov" + row.css('a').first['href'].strip
          raw_date = row.previous.previous.text
          date = begin Date.parse(raw_date) rescue nil end
          results << { :source => url,
                       :url => release_url,
                       :title => title,
                       :date => date,
                       :domain => 'www.rules.senate.gov',
                       :party => "majority" }
      end
      results
    end

    def self.senate_rules_minority(page=1)
      results = []
      url = "https://www.rules.senate.gov/news/minority-news"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          title = row.text.strip
          release_url = "https://www.rules.senate.gov" + row.css('a').first['href'].strip
          raw_date = row.previous.previous.text
          date = begin Date.parse(raw_date) rescue nil end
          results << { :source => url,
                       :url => release_url,
                       :title => title,
                       :date => date,
                       :domain => 'www.rules.senate.gov',
                       :party => "minority" }
      end
      results
    end

    def self.senate_intel(page=0)
      results = []
      url = "https://www.intelligence.senate.gov/press?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").each do |row|
        results << { :source => url, :url => "https://www.intelligence.senate.gov"+row.children[3].css('a').first['href'], :title => row.children[3].text.strip, :date => Date.strptime(row.children[1].text.strip, "%m/%d/%Y"), :domain => "www.intelligence.senate.gov", party: nil }
      end
      results
    end

    def self.senate_smallbiz_majority(page=1)
      results = []
      url = "https://www.sbc.senate.gov/public/index.cfm/republicanpressreleases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']").css('tr')[1..-1].each do |row|
        next if row.children[1].text.strip == 'Date'
        results << { :source => url, :url => "https://www.sbc.senate.gov/"+row.children[3].css('a').first['href'], :title => row.children[3].text.strip, :date => Date.strptime(row.children[1].text.strip, "%m/%d/%y"), :domain => "www.sbc.senate.gov", :party => 'majority' }
      end
      results
    end

    def self.senate_smallbiz_minority(page=1)
      results = []
      url = "https://www.sbc.senate.gov/public/index.cfm/democraticpressreleases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']").css('tr')[1..-1].each do |row|
        next if row.children[1].text.strip == 'Date'
        results << { :source => url, :url => "https://www.sbc.senate.gov/"+row.children[3].css('a').first['href'], :title => row.children[3].text.strip, :date => Date.strptime(row.children[1].text.strip, "%m/%d/%y"), :domain => "www.sbc.senate.gov", :party => 'minority' }
      end
      results
    end

    ## House committees

    def self.house_ag_majority(page=1)
      results = []
      url = "https://agriculture.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << { :source => url, :url => "https://agriculture.house.gov/news/"+row.css("h3 a").first['href'], :title => row.css('h3').first.text.strip, :date => Date.parse(row.css('time').text), :domain => "agriculture.house.gov", :party => 'majority' }
      end
      results
    end

    def self.house_ag_minority(page=1)
      results = []
      url = "https://republicans-agriculture.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='middlecopy']//li").each do |row|
        results << { :source => url, :url => "https://republicans-agriculture.house.gov" + row.children[1]['href'], :title => row.children[1].text.strip, :date => Date.parse(row.children[3].text.strip), :domain => 'agriculture.house.gov', :party => "minority" }
      end
      results
    end

    def self.house_approps_minority(page=1)
      results = []
      url = "https://republicans-appropriations.house.gov/news/documentquery.aspx?DocumentTypeID=2151&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//ul[@class='UnorderedNewsList']//li").each do |row|
        results << { :source => url, :url => "https://republicans-appropriations.house.gov/news/" + row.css('a').first['href'], :title => row.css('h2').text.strip, :date => Date.parse(row.css('b').text.strip), :domain => 'appropriations.house.gov', :party => "minority" }
      end
      results
    end

    def self.house_armedservices_majority(page=1)
      results = []
      url = "https://armedservices.house.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[3].text.strip == 'Title'
        results << { :source => url, :url => "https://armedservices.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "armedservices.house.gov", :party => "majority" }
      end
      results
    end

    def self.house_armedservices_minority(page=0)
      results = []
      url = "https://republicans-armedservices.house.gov/news/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").each do |row|
        results << { :source => url, :url => "https://republicans-armedservices.house.gov"+row.css('a').first['href'], :title => row.css('a').first.text, :date => Date.parse(row.children[3].text.strip), :domain => "armedservices.house.gov", party: 'minority' }
      end
      results
    end

    def self.house_education_majority(page=1)
      results = []
      url = "https://edlabor.house.gov/media/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#press h2").each do |row|
        results << { :source => url, :url => "https://edlabor.house.gov"+row.css('a').first['href'], :title => row.css('a').text, :date => Date.strptime(row.next.next.css('strong').text.strip, "%m.%d.%y"), :domain => "edlabor.house.gov", party: 'majority' }
      end
      results
    end

    def self.house_energy_majority(page=0)
      results = []
      url = "https://energycommerce.house.gov/newsroom/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").each do |row|
        results << { :source => url, :url => "https://energycommerce.house"+row.css('a').first['href'], :title => row.css('a').first.text, :date => Date.parse(row.css(".views-field-created").text.strip), :domain => "energycommerce.house.gov", party: 'majority' }
      end
      results
    end

    def self.house_ethics
      results = []
      url = "https://ethics.house.gov/media-center"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").each do |row|
        results << { :source => url, :url => "https://ethics.house.gov"+row.css('a').first['href'], :title => row.css('a').text, :date => Date.parse(row.css('.field-content')[1].text), :domain => "ethics.house.gov", :party => nil }
      end
      results
    end

    def self.house_financial_services_majority(page=1)
      results = []
      url = "https://financialservices.house.gov/news/documentquery.aspx?DocumentTypeID=2636&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << { :source => url, :url => "https://financialservices.house.gov/news/"+row.css('a').first['href'], :title => row.css('h3').text.strip, :date => Date.parse(row.css('time').text), :domain => "financialservices.house.gov", :party => 'majority' }
      end
      results
    end

    def self.house_financial_services_minority(page=1)
      results = []
      url = "https://republicans-financialservices.house.gov/news/documentquery.aspx?DocumentTypeID=2092&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('ul.UnorderedNewsList li').each do |row|
        next if row.text.strip.size < 10
        results << { :source => url, :url => "https://republicans-financialservices.house.gov"+row.css('a').first['href'], :title => row.css('a').first.text.strip, :date => Date.parse(row.css('b').text.strip), :domain => "financialservices.house.gov", :party => 'minority' }
      end
      results
    end

    def self.house_foreign_affairs_majority(page=1)
      results = []
      url = "https://foreignaffairs.house.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('.recordList tr')[1..-1].each do |row|
        next if row.css('a').empty?
        results << { :source => url, :url => "https://foreignaffairs.house.gov"+row.css('a').first['href'], :title => row.css('a').text.strip, :date => Date.strptime(row.css('.recordListDate').text, '%m/%d/%y'), :domain => "foreignaffairs.house.gov", :party => 'majority' }
      end
      results
    end

    def self.house_homeland_security_majority(page=0)
      results = []
      url = "https://homeland.house.gov/news/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").each do |row|
        results << { :source => url, :url => "https://homeland.house.gov"+row.css('a').first['href'], :title => row.css('h3').text.strip, :date => Date.parse(row.css('.views-field-created').text.strip), :domain => "homeland.house.gov", :party => 'majority' }
      end
      results
    end

    def self.house_administration_majority(page=0)
      results = []
      url = "https://cha.house.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".list-item").each do |row|
        results << { :source => url, :url => "https://cha.house.gov"+row.css('a').first['href'], :title => row.css('a').text.strip, :date => Date.parse(row.css(".date").text), :domain => "cha.house.gov", :party => 'majority' }
      end
      results
    end

    def self.house_administration_minority(page=0)
      results = []
      url = "https://republicans-cha.house.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".list-item").each do |row|
        results << { :source => url, :url => "https://cha.house.gov"+row.css('a').first['href'], :title => row.css('a').text.strip, :date => Date.parse(row.css(".date").text), :domain => "cha.house.gov", :party => 'minority' }
      end
      results
    end

    def self.house_judiciary_minority(page=1)
      results = []
      url = "https://republicans-judiciary.house.gov/press-releases/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('article').each do |row|
        results << { :source => url, :url => row.css('a').first['href'], :title => row.css('h3').text, :date => Date.parse(row.css('.date').text), :domain => "judiciary.house.gov", :party => 'minority' }
      end
      results
    end

    def self.house_resources_majority(page=1)
      results = []
      url = "https://naturalresources.house.gov/media/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#press h2").each do |row|
        results << { :source => url, :url => "https://naturalresources.house.gov"+row.css('a').first['href'], :title => row.css('a').text.strip, :date => Date.strptime(row.previous.previous.text, '%m.%d.%y'), :domain => "naturalresources.house.gov", :party => 'majority' }
      end
      results
    end

    def self.house_science_majority(page=1)
      results = []
      url = "https://science.house.gov/news/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#press h3").each do |row|
        results << { :source => url, :url => "https://science.house.gov"+row.css('a').first['href'], :title => row.css('a').text.strip, :date => Date.parse(row.previous.previous.text), :domain => "science.house.gov", :party => 'majority' }
      end
      results
    end

    def self.house_science_minority(page=0)
      results = []
      url = "https://republicans-science.house.gov/news/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").each do |row|
        results << { :source => url, :url => "https://republicans-science.house.gov"+row.css('a').first['href'], :title => row.css('a').text.strip, :date => Date.parse(row.css(".views-field-created").text.strip), :domain => "science.house.gov", :party => 'minority' }
      end
      results
    end

    def self.house_smallbiz_majority(page=1)
      results = []
      url = "https://smallbusiness.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << { :source => url, :url => "https://smallbusiness.house.gov/news/"+row.css('a').first['href'], :title => row.css('a').first.text.strip, :date => Date.parse(row.css('time').text), :domain => "smallbusiness.house.gov", :party => 'majority' }
      end
      results
    end

    def self.house_smallbiz_minority(page=1)
      results = []
      url = "https://republicans-smallbusiness.house.gov/news/documentquery.aspx?DocumentTypeID=1684&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//ul[@class='UnorderedNewsList']//li").each do |row|
        results << { :source => url, :url => "https://republicans-smallbusiness.house.gov/news/"+row.css('a').first['href'], :title => row.css('a').first.text.strip, :date => Date.parse(row.children[3].text.strip), :domain => "smallbusiness.house.gov", :party => 'minority' }
      end
      results
    end

    def self.house_transportation_majority(page=1)
      results = []
      url = "https://transportation.house.gov/news/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#press h2").each do |row|
        results << { :source => url, :url => "https://transportation.house.gov"+row.css('a').first['href'], :title => row.css('a').text, :date => Date.parse(row.next.next.text), :domain => "transportation.house.gov", party: 'majority' }
      end
      results
    end

    def self.house_transportation_minority(page=1)
      results = []
      url = "https://republicans-transportation.house.gov/news/documentquery.aspx?DocumentTypeID=2545&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//ul[@class='UnorderedNewsList']//li").each do |row|
        results << { :source => url, :url => "https://republicans-transportation.house.gov/news/"+row.css('a').first['href'], :title => row.css('a').first.text.strip, :date => Date.parse(row.children[3].text.strip), :domain => "smallbusiness.house.gov", :party => 'minority' }
      end
      results
    end

    def self.house_veterans_minority(page=1)
      results = []
      url = "https://republicans-veterans.house.gov/news/documentquery.aspx?DocumentTypeID=2613&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//ul[@class='UnorderedNewsList']//li").each do |row|
        results << { :source => url, :url => "https://republicans-veterans.house.gov/news/"+row.css('a').first['href'], :title => row.css('a').first.text.strip, :date => Date.parse(row.children[1].children[2].text.strip), :domain => "veterans.house.gov", :party => 'minority' }
      end
      results
    end

    def self.house_intel_majority(page=1)
      results = []
      url = "https://intelligence.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << { :source => url, :url => "https://intelligence.house.gov/news/"+row.css('a').first['href'], :title => row.css('a').first.text.strip, :date => Date.parse(row.css('time').text), :domain => "intelligence.house.gov", :party => 'majority' }
      end
      results
    end

    def self.house_intel_minority(page=1)
      results = []
      url = "https://republicans-intelligence.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//ul[@class='UnorderedNewsList']//li").each do |row|
        results << { :source => url, :url => "https://republicans-intelligence.house.gov/news/"+row.css('a').first['href'], :title => row.css('a').first.text.strip, :date => Date.parse(row.children[3].text.strip), :domain => "intelligence.house.gov", :party => 'minority' }
      end
      results
    end

    def self.house_climate_majority(page=0)
      results = []
      url = "https://climatecrisis.house.gov/news/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").each do |row|
        results << { :source => url, :url => "https://climatecrisis.house.gov"+row.css('a').first['href'], :title => row.css('a').first.text.strip, :date => Date.parse(row.css(".views-field-created").text.strip), :domain => "climatecrisis.house.gov", :party => 'majority' }
      end
      results
    end

    def self.house_modernization(page=0)
      results = []
      url = "https://modernizecongress.house.gov/news/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").each do |row|
        results << { :source => url, :url => "https://modernizecongress.house.gov"+row.css('a').first['href'], :title => row.css('a').first.text.strip, :date => Date.parse(row.css(".views-field-created").text.strip), :domain => "modernizecongress.house.gov", :party => nil }
      end
      results
    end

    def self.hoyer
      results = []
      url = "https://hoyer.house.gov/newsroom"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").each do |row|
        results << { :source => url, :url => "https://hoyer.house.gov"+row.css('a').first['href'], :title => row.css('a').first.text.strip, :date => begin Date.parse(row.css(".views-field-created").text.strip) rescue Time.zone.today end, :domain => "hoyer.house.gov" }
      end
      results
    end

    ## special cases for members without RSS feeds

    def self.house_title_header(urls=[], page=1)
      if urls.empty?
        urls = [
          "https://halrogers.house.gov/press-releases",
          "https://fulcher.house.gov/press-releases",
          "https://mcbath.house.gov/press-releases",
          "https://markgreen.house.gov/press-releases",
          "https://adamsmith.house.gov/press-releases",
          "https://lahood.house.gov/press-releases",
          "https://sewell.house.gov/press-releases"
        ]
     end
     results = []

     urls.each do |url|
       puts url
       uri = URI(url)
       source_url = "#{url}?page=#{page}"
       domain =  URI.parse(source_url).host
       doc = open_html(source_url)
       return if doc.nil?
       doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
         next if row.children[3].text.strip == 'Title'
         results << { :source => url, :url => "https://"+domain+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => domain }
       end
     end
     results
    end

    def self.media_body(urls=[], page=0)
      if urls.empty?
        urls = [
          "https://issa.house.gov/media/press-releases",
          "https://tenney.house.gov/media/press-releases",
          "https://amodei.house.gov/news-releases",
          "https://palmer.house.gov/media-center/press-releases",
          "https://newhouse.house.gov/media-center/press-releases",
          "https://doggett.house.gov/media/press-releases",
          "https://ocasio-cortez.house.gov/media/press-releases",
          "https://hudson.house.gov/media/press-releases",
          "https://davis.house.gov/media",
          "https://espaillat.house.gov/media/press-releases",
          "https://algreen.house.gov/media/press-releases",
          "https://mariodiazbalart.house.gov/media-center/press-releases",
          "https://meeks.house.gov/media/press-releases",
          "https://biggs.house.gov/media/press-releases",
          "https://johnjoyce.house.gov/media/press-releases",
          "https://blumenauer.house.gov/media-center/press-releases",
          "https://larson.house.gov/media-center/press-releases",
          "https://kaptur.house.gov/media-center/press-releases",
          "https://benniethompson.house.gov/media/press-releases",
          "https://walberg.house.gov/media/press-releases",
          "https://allred.house.gov/media/press-releases",
          "https://burchett.house.gov/media/press-releases",
          "https://cline.house.gov/media/press-releases",
          "https://golden.house.gov/media/press-releases",
          "https://harder.house.gov/media/press-releases",
          "https://dustyjohnson.house.gov/media/press-releases",
          "https://meuser.house.gov/media/press-releases",
          "https://miller.house.gov/media/press-releases",
          "https://johnrose.house.gov/media/press-releases",
          "https://roy.house.gov/media/press-releases",
          "https://sherrill.house.gov/media/press-releases",
          "https://steil.house.gov/media/press-releases",
          "https://schrier.house.gov/media/press-releases",
          "https://cherfilus-mccormick.house.gov/media/press-releases",
          "https://carey.house.gov/media/press-releases",
          "https://shontelbrown.house.gov/media/press-releases",
          "https://stansbury.house.gov/media/press-releases",
          "https://troycarter.house.gov/media/press-releases",
          "https://letlow.house.gov/media/press-releases",
          "https://slotkin.house.gov/media/press-releases",
          "https://matsui.house.gov/media",
          "https://harris.house.gov/media/press-releases",
          "https://wagner.house.gov/media-center/press-releases",
          "https://kim.house.gov/media/press-releases",
          "https://pappas.house.gov/media/press-releases",
          "https://crow.house.gov/media/press-releases",
          "https://chuygarcia.house.gov/media/press-releases",
          "https://omar.house.gov/media/press-releases",
          "https://underwood.house.gov/media/press-releases",
          "https://casten.house.gov/media/press-releases",
          "https://pence.house.gov/media/press-releases",
          "https://fleischmann.house.gov/media/press-releases",
          "https://stevens.house.gov/media/press-releases",
          "https://guest.house.gov/media/press-releases",
          "https://armstrong.house.gov/media/press-releases",
          "https://morelle.house.gov/media/press-releases",
          "https://rubengallego.house.gov/media-center/press-releases",
          "https://beatty.house.gov/media-center/press-releases",
          "https://robinkelly.house.gov/media-center/press-releases",
          "https://clayhiggins.house.gov/media/press-releases",
          "https://moolenaar.house.gov/media-center/press-releases",
          "https://adams.house.gov/media-center/press-releases",
          "https://mfume.house.gov/media/press-releases",
          "https://tiffany.house.gov/media/press-releases",
          "https://carl.house.gov/media/press-releases",
          "https://barrymoore.house.gov/media/press-releases",
          "https://obernolte.house.gov/media/press-releases",
          "https://youngkim.house.gov/media/press-releases",
          "https://steel.house.gov/media/press-releases",
          "https://boebert.house.gov/media/press-releases",
          "https://cammack.house.gov/media/press-releases",
          "https://salazar.house.gov/media/press-releases",
          "https://hinson.house.gov/media/press-releases",
          "https://millermeeks.house.gov/media/press-releases",
          "https://feenstra.house.gov/media/press-releases",
          "https://marymiller.house.gov/media/press-releases",
          "https://mrvan.house.gov/media/press-releases",
          "https://spartz.house.gov/media/press-releases",
          "https://mann.house.gov/media/press-releases",
          "https://laturner.house.gov/media/press-releases",
          "https://manning.house.gov/media/press-releases",
          "https://fernandez.house.gov/media/press-releases",
          "https://garbarino.house.gov/media/press-releases",
          "https://malliotakis.house.gov/media/press-releases",
          "https://bice.house.gov/media/press-releases",
          "https://bentz.house.gov/media/press-releases",
          "https://mace.house.gov/media/press-releases",
          "https://harshbarger.house.gov/media/press-releases",
          "https://fallon.house.gov/media/press-releases",
          "https://blakemoore.house.gov/media/press-releases",
          "https://strickland.house.gov/media/press-releases",
          "https://fitzgerald.house.gov/media/press-releases",
          "https://flood.house.gov/media/press-releases",
          "https://patryan.house.gov/media/press-releases",
          "https://kamlager-dove.house.gov/media/press-releases",
          "https://robertgarcia.house.gov/media/press-releases",
          "https://bean.house.gov/media/press-releases",
          "https://mccormick.house.gov/media/press-releases",
          "https://collins.house.gov/media/press-releases",
          "https://edwards.house.gov/media/press-releases",
          "https://kean.house.gov/media/press-releases",
          "https://goldman.house.gov/media/press-releases",
          "https://langworthy.house.gov/media/press-releases",
          "https://chavez-deremer.house.gov/media/press-releases",
          "https://magaziner.house.gov/media/press-releases",
          "https://vanorden.house.gov/media/press-releases",
          "https://hunt.house.gov/media/press-releases",
          "https://casar.house.gov/media/press-releases",
          "https://crockett.house.gov/media/press-releases",
          "https://luttrell.house.gov/media/press-releases",
          "https://moran.house.gov/media/press-releases",
          "https://deluzio.house.gov/media/press-releases",
          "https://sykes.house.gov/media/press-releases",
          "https://desposito.house.gov/media/press-releases",
          "https://lalota.house.gov/media/press-releases",
          "https://vasquez.house.gov/media/press-releases",
          "https://alford.house.gov/media/press-releases",
          "https://thanedar.house.gov/media/press-releases",
          "https://james.house.gov/media/press-releases",
          "https://scholten.house.gov/media/press-releases",
          "https://ivey.house.gov/media/press-releases",
          "https://mcgarvey.house.gov/media/press-releases",
          "https://sorensen.house.gov/media/press-releases",
          "https://nunn.house.gov/media/press-releases",
          "https://tokuda.house.gov/media/press-releases",
          "https://laurellee.house.gov/media/press-releases",
          "https://mills.house.gov/media/press-releases",
          "https://kevinmullin.house.gov/media/press-releases",
          "https://ciscomani.house.gov/media/press-releases",
          "https://crane.house.gov/media/press-releases",
          "https://democraticleader.house.gov/media/press-releases",
          "https://buck.house.gov/media-center/press-releases",
          "https://horsford.house.gov/media/press-releases",
          "https://cleaver.house.gov/media-center/press-releases",
          "https://aderholt.house.gov/media-center/press-releases",
          "https://courtney.house.gov/media-center/press-releases",
          "https://stauber.house.gov/media/press-releases",
          "https://mccaul.house.gov/media-center/press-releases",
          "https://jeffduncan.house.gov/media/press-releases",
          "https://foster.house.gov/media/press-releases",
          "https://schakowsky.house.gov/media/press-releases",
          "https://craig.house.gov/media/press-releases",
          "https://bera.house.gov/media-center/press-releases",
          "https://desaulnier.house.gov/media-center/press-releases",
          "https://scalise.house.gov/media/press-releases",
          "https://neguse.house.gov/media/press-releases",
          "https://murphy.house.gov/media/press-releases",
          "https://boyle.house.gov/media-center/press-releases",
          "https://calvert.house.gov/media/press-releases",
          "https://ruppersberger.house.gov/news-room/press-releases",
          "https://bobbyscott.house.gov/media-center/press-releases",
          "https://bilirakis.house.gov/media/press-releases",
          "https://delauro.house.gov/media-center/press-releases",
          "https://norton.house.gov/media/press-releases",
          "https://mikethompson.house.gov/newsroom/press-releases",
          "https://smucker.house.gov/media/press-releases",
          "https://degette.house.gov/media-center/press-releases",
          "https://ruiz.house.gov/media-center/press-releases"
        ]
      end
      results = []
      urls.each do |url|
        puts url
        uri = URI(url)
        source_url = "#{url}?page=#{page}"
        domain =  URI.parse(source_url).host
        doc = open_html(source_url)
        return if doc.nil?
        doc.css(".media-body").each do |row|
          results << { :source => url, :url => "https://"+domain+row.css('a').first['href'], :title => row.css('a').first.text, :date => Date.parse(row.css('.row .col-auto').first.text.strip), :domain => domain }
        end
      end
      results
    end

    def self.webster
      results = []
      url = "https://webster.house.gov/press-releases"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[1].text == 'Date'
        results << { :source => url, :url => "https://webster.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "webster.house.gov" }
      end
      results
    end

    def self.ellzey(page=1)
      results = []
      url = "https://ellzey.house.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[1].text == 'Date'
        results << { :source => url, :url => "https://ellzey.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "ellzey.house.gov" }
      end
      results
    end

    def self.mast(page=1)
      results = []
      url = "https://mast.house.gov/press-releases"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[1].text == 'Date'
        results << { :source => url, :url => "https://mast.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "mast.house.gov" }
      end
      results
    end

    def self.gimenez(page=1)
      results = []
      url = "https://gimenez.house.gov/press-releases"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[1].text == 'Date'
        results << { :source => url, :url => "https://gimenez.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "gimenez.house.gov" }
      end
      results
    end

    def self.cold_fusion(year=current_year, month=nil, skip_domains=[])
      results = []
      year = current_year if not year
      domains = ['www.wicker.senate.gov', 'www.enzi.senate.gov']
      domains = domains - skip_domains if skip_domains
      domains.each do |domain|
        if domain == 'www.wicker.senate.gov'
          if not month
            url = "https://#{domain}/public/index.cfm/press-releases"
          else
            url = "https://#{domain}/public/index.cfm/press-releases?YearDisplay=#{year}&MonthDisplay=#{month}&page=1"
          end
        elsif domain == 'www.mcconnell.senate.gov'
          if not month
            url = "https://#{domain}/public/index.cfm/pressreleases"
          else
            url = "https://#{domain}/public/index.cfm/pressreleases?YearDisplay=#{year}&MonthDisplay=#{month}&page=1"
          end
        else
          if not month
            url = "https://#{domain}/public/index.cfm/press-releases"
          else
            url = "https://#{domain}/public/index.cfm/press-releases?YearDisplay=#{year}&MonthDisplay=#{month}&page=1"
          end
        end
        doc = Statement::Scraper.open_html(url)
        return if doc.nil?
        return if doc.xpath("//tr").empty?
        if domain == 'www.lee.senate.gov' or domain == 'www.barrasso.senate.gov' or domain == "www.heitkamp.senate.gov" or domain == 'www.moran.senate.gov' or domain == 'www.feinstein.senate.gov' or domain == 'www.shelby.senate.gov'
          rows = doc.xpath("//tr")[1..-1]
        else
          rows = doc.xpath("//tr")[2..-1]
        end
        rows.each do |row|
          date_text, title = row.children.map{|c| c.text.strip}.reject{|c| c.empty?}
          next if date_text == 'Date' or date_text.size > 10
          date = Date.parse(date_text)
          url = row.children[3].children.first['href'].chars.first == '/' ? "http://#{domain}"+row.children[3].children.first['href'] : row.children[3].children.first['href']
          results << { :source => url, :url => url, :title => title, :date => date, :domain => domain }
        end
      end
      results.flatten
    end

    def self.mcmorris
      results = []
      url = "https://mcmorris.house.gov/press"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      json = JSON.load(doc.at_css('[id="__NEXT_DATA__"]').text)
      posts = json['props']['pageProps']['dehydratedState']['queries'][11]['state']['data']['posts']['edges']
      posts.each do |post|
        results << { :source => url, :url => post['node']['link'], :title => post['node']['title'], :date => Date.parse(post['node']['date']), :domain => 'mcmorris.house.gov'}
      end
      results
    end

    def self.react(domains=[])
      if domains == []
        domains = [
          "nikemawilliams.house.gov",
          "kiley.house.gov",
          "nehls.house.gov",
          "yakym.house.gov",
          "ritchietorres.house.gov",
          "cloud.house.gov",
          "owens.house.gov",
          "budzinski.house.gov",
          "gluesenkampperez.house.gov",
          "landsman.house.gov"
        ]
      end
      results = []
      domains.each do |domain|
        url = "https://#{domain}/press"
        doc = Statement::Scraper.open_html(url)
        next if doc.nil?
        json = JSON.load(doc.at_css('[id="__NEXT_DATA__"]').text)
        posts = json['props']['pageProps']['dehydratedState']['queries'][11]['state']['data']['posts']['edges']
        posts.each do |post|
          results << { :source => url, :url => post['node']['link'], :title => post['node']['title'], :date => Date.parse(post['node']['date']), :domain => domain}
        end
      end
      results
    end

    def self.klobuchar(year=current_year, month=0, page=1)
      results = []
      url = "https://www.klobuchar.senate.gov/public/index.cfm/news-releases?MonthDisplay=#{month}&YearDisplay=#{year}&page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      return if doc.xpath("//tr").empty?
      doc.xpath("//tr")[2..-1].each do |row|
        next if row.text.strip[0..3] == "Date"
        results << { :source => url, :url => "https://www.klobuchar.senate.gov" + row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.strptime(row.children[1].text.strip, "%m/%d/%y"), :domain => "www.klobuchar.senate.gov" }
      end
      results
    end

    def self.tillis(page=1)
      results = []
      url = "https://www.tillis.senate.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".element").each do |row|
        results << { :source => url, :url => row.css('a').first['href'], :title => row.css(".element-title").text, :date => Date.strptime(row.css(".element-datetime").text, "%m/%d/%Y"), :domain => "www.tillis.senate.gov" }
      end
      results
    end

    def self.article_block(urls=[], page=1)
      if urls.empty?
        urls = [
          "https://www.coons.senate.gov/news/press-releases",
          "https://www.booker.senate.gov/news/press",
          "https://www.cramer.senate.gov/news/press-releases"
        ]
      end
      results = []

      urls.each do |url|
       puts url
       uri = URI(url)
       source_url = "#{url}?pagenum_rs=#{page}"
       domain =  URI.parse(source_url).host
       doc = open_html(source_url)
       return if doc.nil?
       doc.css(".ArticleBlock").each do |row|
         results << { :source => url, :url => row.css('a').first['href'], :title => row.css('h3').text.strip, :date => Date.parse(row.css('.ArticleBlock__date').text), :domain => domain }
       end
      end
      results
    end

    def self.article_block_h1(urls=[], page=1)
      if urls.empty?
        urls = [
          "https://www.markey.senate.gov/news/press-releases",
          "https://www.murphy.senate.gov/newsroom/press-releases",
          "https://www.cotton.senate.gov/news/press-releases",
          "https://www.menendez.senate.gov/newsroom/press"
        ]
      end
      results = []

      urls.each do |url|
       puts url
       uri = URI(url)
       source_url = "#{url}?pagenum_rs=#{page}"
       domain =  URI.parse(source_url).host
       doc = open_html(source_url)
       return if doc.nil?
       doc.css(".ArticleBlock").each do |row|
         results << { :source => url, :url => row.css('a').first['href'], :title => row.css('a').text.strip, :date => Date.parse(row.css('.ArticleBlock__date').text), :domain => domain }
       end
      end
      results
    end

    def self.article_block_h2(urls=[], page=1)
      if urls.empty?
        urls = [
          "https://www.brown.senate.gov/newsroom/press-releases"
        ]
      end
      results = []

      urls.each do |url|
       puts url
       uri = URI(url)
       source_url = "#{url}?pagenum_rs=#{page}"
       domain =  URI.parse(source_url).host
       doc = Statement::Scraper.open_html(source_url)
       return if doc.nil?
       doc.css(".ArticleBlock").each do |row|
         results << { :source => url, :url => row.css('a').first['href'], :title => row.css("h2").text.strip, :date => Date.parse(row.css('.ArticleBlock__date').text), :domain => domain }
       end
      end
      results
    end

    def self.article_block_h2_date(urls=[], page=1)
      results = []

      if urls.empty?
        urls = [
          "https://www.blumenthal.senate.gov/newsroom/press",
          "https://www.collins.senate.gov/newsroom/press-releases"
        ]
      end

      urls.each do |url|
        puts url
        uri = URI(url)
        source_url = "#{url}?pagenum_rs=#{page}"
        domain =  URI.parse(source_url).host
        doc = Statement::Scraper.open_html(source_url)
        return if doc.nil?
        doc.css(".ArticleBlock").each do |row|
          results << { :source => url, :url => row.css('a').first['href'], :title => row.css("h2").text.strip, :date => Date.parse(row.css('p').text), :domain => domain }
        end
      end
      results
    end

    def self.schiff(page=1)
      results = []
      url = "https://schiff.house.gov/news/press-releases?PageNum_rs=#{page}&"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css("#press").first.css('h2')
      rows.each do |row|
        results << { :source => url, :url => "https://schiff.house.gov" + row.css('a').first['href'], :title => row.css('a').first.text, :date => Date.parse(row.previous.previous.text), :domain => "schiff.house.gov" }
      end
      results
    end

    def self.moulton(page=1)
      results = []
      url = "https://moulton.house.gov/media/press-releases?PageNum_rs=#{page}&"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css("#press").first.css('h2')
      rows.each do |row|
        results << { :source => url, :url => "https://moulton.house.gov" + row.css('a')[0]['href'], :title => row.children[1].text.strip, :date => Date.parse(row.previous.previous.text), :domain => "moulton.house.gov" }
      end
      results
    end

    def self.kilmer(page=1)
      results = []
      url = "https://kilmer.house.gov/news/press-releases?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      rows = doc.css("#press").first.css('h2')
      rows.each do |row|
        results << { :source => url, :url => "https://kilmer.house.gov" + row.css('a').first['href'], :title => row.css('a').text.strip, :date => Date.parse(row.previous.previous.text), :domain => "kilmer.house.gov" }
      end
      results
    end

    def self.takano(page=1)
      results = []
      url = "https://takano.house.gov/newsroom/press-releases?PageNum_rs=#{page}"
      doc = open_html(url)
      return if doc.nil?
      rows = doc.css("#press").first.css('h2')
      rows.each do |row|
        results << { :source => url, :url => "https://takano.house.gov" + row.css('a').first['href'], :title => row.text.strip, :date => Date.parse(row.previous.previous.text), :domain => "takano.house.gov" }
      end
      results
    end

    def self.angusking(page=1)
      results = []
      url = "https://www.king.senate.gov/newsroom/press-releases/table?pagenum_rs=#{page}"
      doc = open_html(url)
      return if doc.nil?
      rows = doc.css('table tr')[1..-1]
      rows.each do |row|
        next if row.css('a').empty?
        results << { :source => url, :url => "https://www.king.senate.gov" + row.css('a')[0]['href'], :title => row.css('a')[0].text.strip, :date => Date.strptime(row.children[1].text.strip, "%m/%d/%y"), :domain => "www.king.senate.gov" }
      end
      results
    end

    def self.cassidy(page=1)
      results = []
      url = "https://www.cassidy.senate.gov/newsroom/press-releases/?jsf=jet-engine:press-list&pagenum=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css(".jet-listing-grid__item")
      rows.each do |row|
        results << { :source => url, :url => row.css("a").first['href'], :title => row.css("a").text.strip, :date => Date.strptime(row.css("ul li").text.strip, "%m.%d.%Y"), :domain => "www.cassidy.senate.gov" }
      end
      results
    end

    def self.cornyn(page=0)
      results = []
      url = "https://www.cornyn.senate.gov/newsroom?field_news_category_tid=1&&date_filter[value]&page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css(".view-content p").each do |row|
        results << { :source => url, :url => "https://www.cornyn.senate.gov" + row.children[0]['href'], :title => row.children[0].text.strip, :date => Date.strptime(row.children[3].text, "%m/%d/%y"), :domain => "www.cornyn.senate.gov" }
      end
      results
    end

    def self.crapo(page=1)
      results = []
      url = "https://www.crapo.senate.gov/media/newsreleases/?PageNum_rs=#{page}&"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.ArticleBlock").each do |row|
        results << { :source => url, :url => row.at('a')['href'], :title => row.at('a').text.strip, :date => Date.parse(row.css('p').text), :domain => 'www.crapo.senate.gov'}
      end
      results
    end

    def self.fischer(page=1)
      results = []
      url = "https://www.fischer.senate.gov/public/index.cfm/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//tr")[2..-1].each do |row|
        next if row.text.strip[0..3] == "Date"
        results << { :source => url, :url => row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.strptime(row.children[1].text.strip, "%m/%d/%y"), :domain => "www.fischer.senate.gov" }
      end
      results
    end

    def self.grassley(page=1)
      results = []
      url = "https://www.grassley.senate.gov/news/news-releases?pagenum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//li[@class='PageList__item']").each do |row|
        results << { :source => url, :url => row.css('a').first['href'], :title => row.css('a').first.text.strip, :date => Date.parse(row.css('p').text.gsub('.','/')), :domain => "www.grassley.senate.gov" }
      end
      results
    end

    def self.kennedy(page=1)
      results = []
      url = "https://www.kennedy.senate.gov/public/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[3].text.strip == 'Title'
        results << { :source => url, :url => "https://www.kennedy.senate.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "www.kennedy.senate.gov" }
      end
      results
    end

    def self.durbin(page=1)
      results = []
      url = "https://www.durbin.senate.gov/newsroom/press-releases?PageNum_rs=#{page}&"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//div[@id='press']//h2").each do |row|
        results << { :source => url, :url => "https://www.durbin.senate.gov"+row.children[0]['href'], :title => row.children[1].text.strip, :date => Date.parse(row.previous.previous.text.gsub(".","/")), :domain => 'www.durbin.senate.gov'}
      end
      results
    end

    def self.garypeters(page=1)
      results = []
      url = "https://www.peters.senate.gov/newsroom/press-releases?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@id='press']//h2").each do |row|
        results << { :source => url, :url => "https://www.peters.senate.gov"+row.children[0]['href'], :title => row.children[0].text.strip, :date => Date.parse(row.previous.previous.text.gsub(".","/")), :domain => 'www.peters.senate.gov'}
      end
      results
    end

    def self.rounds(page=1)
      results = []
      url = "https://www.rounds.senate.gov/newsroom/press-releases?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@id='press']//h2").each do |row|
        results << { :source => url, :url => "https://www.rounds.senate.gov"+row.children[0]['href'], :title => row.children[0].text.strip, :date => Date.parse(row.previous.previous.text.gsub(".","/")), :domain => 'www.rounds.senate.gov'}
      end
      results
    end

    def self.sullivan(page=1)
      results = []
      url = "https://www.sullivan.senate.gov/newsroom/press-releases?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@id='press']//h2").each do |row|
        results << { :source => url, :url => "https://www.sullivan.senate.gov"+row.children[0]['href'], :title => row.children[0].text.strip, :date => Date.parse(row.previous.previous.text.gsub(".","/")), :domain => 'www.sullivan.senate.gov'}
      end
      results
    end

    def self.jackreed(page=1)
      results = []
      url = "https://www.reed.senate.gov/news/releases?pagenum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.ArticleBlock").each do |row|
        results << { :source => url, :url => row.at('a')['href'], :title => row.at('a').text.strip, :date => Date.parse(row.css("time").first.text), :domain => 'www.reed.senate.gov'}
      end
      results
    end

    def self.casey(page=1)
      results = []
      url = "https://www.casey.senate.gov/news/releases?pagenum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.ArticleBlock").each do |row|
        results << { :source => url, :url => row.at('a')['href'], :title => row.at('a').text.strip, :date => Date.parse(row.css("p").text), :domain => 'www.casey.senate.gov'}
      end
      results
    end

    def self.kaine(page=1)
      results = []
      url = "https://www.kaine.senate.gov/news?pagenum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.ArticleBlock").each do |row|
        results << { :source => url, :url => row.at('a')['href'], :title => row.at('a').text.strip, :date => Date.parse(row.css("p").text), :domain => 'www.kaine.senate.gov'}
      end
      results
    end

    def self.blackburn(page=1)
      results = []
      url = "https://www.blackburn.senate.gov/news/cc8c80c1-d564-4bbb-93a4-f1d772346ae0?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.element").each do |row|
        results << { :source => url, :url => row.at('a')['href'], :title => row.css('div.element-title').text, :date => Date.parse(row.css('span.element-datetime').text), :domain => 'www.blackburn.senate.gov'}
      end
      results
    end

    def self.cardin(page=1)
      results = []
      url = "https://www.cardin.senate.gov/newsroom/press/table?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      doc.css('table tr')[1..-1].each do |row|
        next if row.children[3].nil?
        results << { :source => url, :url => row.children[3].children[1]['href'].strip, :title => row.children[3].children[1].text.strip, :date => Date.parse(row.children[1].children[1]['datetime']), :domain => 'www.cardin.senate.gov'}
      end
      results
    end

    def self.gillibrand(page=1)
      results = []
      url = "https://www.gillibrand.senate.gov/news/press?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          results << { :source => url,
                       :url => "https://www.gillibrand.senate.gov/" + row.css('a').first['href'],
                       :title => row.text.strip,
                       :date => Date.parse(row.previous.previous.text),
                       :domain => 'www.gillibrand.senate.gov' }
      end
      results
    end

    def self.heinrich(page=1)
      results = []
      url = "https://www.heinrich.senate.gov/newsroom/press-releases?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      doc.css('table.table-striped tr').each do |row|
        next if row['class'] == 'divider'
        results << { :source => url, :url => row.children[3].children[0]['href'].strip, :title => row.children[3].children[0].text.strip, :date => Date.parse(row.children[1].children[0]['datetime']), :domain => 'www.heinrich.senate.gov'}
      end
      results
    end

    def self.inhofe(page=1)
      results = []
      url = "https://www.inhofe.senate.gov/newsroom/press-releases?PageNum_rs=#{page}"
      domain = "www.inhofe.senate.gov"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='data-browser']//h2").each do |row|
        next if row.text.strip.size < 30
        results << { :source => url, :url => row.at('a')['href'], :title => row.text.strip, :date => Date.parse(row.next.next.text), :domain => domain}
      end
      results
    end

    def self.clark(page=1)
      results = []
      domain = 'katherineclark.house.gov'
      url = "https://katherineclark.house.gov/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      (doc/:tr)[1..-1].each do |row|
        next if row.children[1].text.strip == 'Date'
        results << { :source => url, :date => Date.parse(row.children[1].text.strip), :title => row.children[3].children.text, :url => "https://katherineclark.house.gov" + row.children[3].children[0]['href'], :domain => domain}
      end
      results
    end

    def self.good(page=0)
      results = []
      domain = 'good.house.gov'
      url = "https://good.house.gov/media/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.mb-4").each do |row|
        results << { :source => url, :url => "https://good.house.gov"+row.at_css("h3 a")['href'], :title => row.at_css("h3 a").text, :date => Date.parse(row.at_css("span.field-content").text), :domain => domain}
      end
      results
    end

    def self.costa(page=1)
      results = []
      domain = 'costa.house.gov'
      url = "https://costa.house.gov/media-center/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css("#region-content .views-row").each do |row|
        results << { :source => url, :url => "https://costa.house.gov"+row.css("h3 a").attr('href').value, :title => row.css("h3 a").text, :date => Date.parse(row.css(".views-field-created").text.strip), :domain => domain}
      end
      results
    end

    def self.clyburn(page=0)
      results = []
      domain = 'clyburn.house.gov'
      url = "https://clyburn.house.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#region-content .views-row").each do |row|
        results << { :source => url, :url => "https://clyburn.house.gov"+row.css("a").attr('href').value, :title => row.css("a").text, :date => Date.parse(row.css(".views-field-created").text.strip), :domain => domain}
      end
      results
    end

    def self.joyce
      results = []
      domain = 'joyce.house.gov'
      url = "https://joyce.house.gov/press"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      json = JSON.load(doc.at_css('[id="__NEXT_DATA__"]').text)
      posts = json['props']['pageProps']['dehydratedState']['queries'][11]['state']['data']['posts']['edges']
      posts.each do |post|
        results << { :source => url, :url => post['node']['link'], :title => post['node']['title'], :date => Date.parse(post['node']['date']), :domain => domain}
      end
      results
    end

    def self.trentkelly(page=1)
      results = []
      domain = 'trentkelly.house.gov'
      url = "https://trentkelly.house.gov/newsroom/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << { :source => url, :url => "https://trentkelly.house.gov/newsroom/" + row.at_css('a')['href'], :title => row.at_css('h3').text, :date => Date.parse(row.at_css('time').text), :domain => domain }
      end
      results
    end

    def self.bacon(page=1)
      results = []
      domain = 'bacon.house.gov'
      url = "https://bacon.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//article").each do |row|
        results << {:source => url, :url => "https://bacon.house.gov/news/" + row.css("h2 a").first['href'], :title => row.css("h2").text.strip, :date => Date.parse(row.css('time').text), :domain => domain }
      end
      results
    end

    def self.larsen(page=1)
      results = []
      domain = 'larsen.house.gov'
      url = "https://larsen.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css('.news-texthold').each do |row|
        results << { :source => url, :url => "https://larsen.house.gov/news/" + row.css('h2 a').first['href'], :title => row.css('h2 a').text.strip, :date => Date.parse(row.css('time').text), :domain => domain }
      end
      results
    end

    def self.cartwright(page=1)
      results = []
      domain = 'cartwright.house.gov'
      url = "https://cartwright.house.gov/news/documentquery.aspx?DocumentTypeID=2442&Page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css('.news-texthold').each do |row|
        results << { :source => url, :url => "https://cartwright.house.gov/news/" + row.css('h2 a').first['href'], :title => row.css('h2 a').text.strip, :date => Date.parse(row.css('time').text), :domain => domain }
      end
      results
    end

    def self.connolly(page=1)
      results = []
      domain = 'connolly.house.gov'
      url = "https://connolly.house.gov/news/documentquery.aspx?DocumentTypeID=1952&Page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css('.news-texthold').each do |row|
        results << { :source => url, :url => "https://connolly.house.gov/news/" + row.css('h2 a').first['href'], :title => row.css('h2 a').text.strip, :date => Date.parse(row.css('time').text), :domain => domain }
      end
      results
    end

    def self.tonko(page=1)
      results = []
      domain = 'tonko.house.gov'
      url = "https://tonko.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css('.news-texthold').each do |row|
        results << { :source => url, :url => "https://tonko.house.gov/news/" + row.css('h2 a').first['href'], :title => row.css('h2 a').text.strip, :date => Date.parse(row.css('time').text), :domain => domain }
      end
      results
    end

    def self.olson(year=current_year)
      results = []
      domain = 'olson.house.gov'
      url = "https://olson.house.gov/#{year}-press-releases/"
      doc = open_html(url)
      return if doc.nil?
      (doc/:h3).each do |row|
        results << {:source => url, :url => 'https://olson.house.gov' + row.children[1]['href'], :title => row.children[1].text.strip, :date => Date.parse(row.next.next.text), :domain => domain }
      end
      results
    end

    def self.document_query(domains=[], page=1)
      results = []
      if domains.empty?
        domains = [
          {'delbene.house.gov' => 27}
        ]
      end
      domains.each do |domain|
        puts domain
        doc = Statement::Scraper.open_html("https://"+domain.keys.first+"/news/documentquery.aspx?DocumentTypeID=#{domain.values.first}&Page=#{page}")
        return if doc.nil?
        doc.xpath("//div[@class='middlecopy']//li").each do |row|
          if domain.keys.first == 'loudermilk.house.gov'
            results << { :source => "https://"+domain.keys.first+"/news/"+"documentquery.aspx?DocumentTypeID=#{domain.values.first}&Page=#{page}", :url => "https://"+domain.keys.first+"/news/" + row.children[1].css('a').first['href'], :title => row.children[1].css('b').first.text, :date => Date.parse(row.children[1].css('b').last.text), :domain => domain.keys.first }
          else
            results << { :source => "https://"+domain.keys.first+"/news/"+"documentquery.aspx?DocumentTypeID=#{domain.values.first}&Page=#{page}", :url => "https://"+domain.keys.first+"/news/" + row.children[1]['href'], :title => row.children[1].text.strip, :date => Date.parse(row.children[3].text.strip), :domain => domain.keys.first }
          end
        end
      end
      results.flatten
    end

    def self.document_query_new(domains=[], page=1)
      results = []
      if domains.empty?
        domains = [
          {"wassermanschultz.house.gov"=>27},
          {'hern.house.gov' => 27},
          {'fletcher.house.gov' => 27},
          {'guthrie.house.gov' => 2381},
          {"pingree.house.gov" => 27},
          {'perry.house.gov' => 2608},
          {"babin.house.gov" => 27},
          {'plaskett.house.gov' => 27},
          {'ferguson.house.gov' => 27},
          {"mikerogers.house.gov" => 27},
          {'nadler.house.gov' => 1753},
          {'debbiedingell.house.gov' => 27},
          {'gomez.house.gov' => 27},
          {"beyer.house.gov" => 27},
          {"waltz.house.gov" => 27},
          {'escobar.house.gov' => 27},
          {'wexton.house.gov' => 27},
          {'arrington.house.gov' => 27},
          {'valadao.house.gov' => 27},
          {'weber.house.gov' => 27},
          {'kuster.house.gov' => 27},
          {"grothman.house.gov" => 27},
          {"norman.house.gov" => 27},
          {"buddycarter.house.gov" => 27},
          {"trahan.house.gov" => 27},
          {"banks.house.gov" => 27},
          {"gwenmoore.house.gov" => 27},
          {'carbajal.house.gov' => 27},
          {"phillips.house.gov" => 27},
          {"timmons.house.gov" => 27},
          {"allen.house.gov" => 27},
          {'estes.house.gov' => 27},
          {'hill.house.gov' => 27},
          {"wittman.house.gov" => 2670},
          {'gosar.house.gov' => 27},
          {'mikejohnson.house.gov' => 27},
          {"perry.house.gov" => 2645},
          {"perry.house.gov" => 2608},
          {"neal.house.gov" => 27},
          {'rouzer.house.gov' => 27}
        ]
      end
      domains.each do |domain|
        puts domain
        source_url = "https://"+domain.keys.first+"/news/documentquery.aspx?DocumentTypeID=#{domain.values.first}&Page=#{page}"
        doc = Statement::Scraper.open_html(source_url)
        return if doc.nil?
        doc.xpath("//article").each do |row|
          results << { :source => source_url, :url => "https://"+domain.keys.first+"/news/" + row.css("h2 a").first['href'], :title => row.css("h2").text.strip, :date => Date.parse(row.css('time').last.text), :domain => domain.keys.first }
        end
      end
      results
    end

    def self.spanberger
      results = []
      url = "https://spanberger.house.gov/resources/press"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      json = JSON.load(doc.at_css('[id="__NEXT_DATA__"]').text)
      posts = json['props']['pageProps']['dehydratedState']['queries'][12]['state']['data']['posts']['edges']
      posts.each do |post|
        results << { :source => url, :url => post['node']['link'], :title => post['node']['title'], :date => Date.parse(post['node']['date']), :domain => 'spanberger.house.gov'}
      end
      results
    end

    def self.crawford
      results = []
      url = "https://crawford.house.gov/resources/uncategorized"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      json = JSON.load(doc.at_css('[id="__NEXT_DATA__"]').text)
      posts = json['props']['pageProps']['dehydratedState']['queries'][12]['state']['data']['posts']['edges']
      posts.each do |post|
        results << { :source => url, :url => post['node']['link'], :title => post['node']['title'], :date => Date.parse(post['node']['date']), :domain => 'crawford.house.gov'}
      end
      results
    end

    def self.lucas
      results = []
      url = "https://lucas.house.gov/press"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      json = JSON.load(doc.at_css('[id="__NEXT_DATA__"]').text)
      posts = json['props']['pageProps']['dehydratedState']['queries'][11]['state']['data']['posts']['edges']
      posts.each do |post|
        results << { :source => url, :url => post['node']['link'], :title => post['node']['title'], :date => Date.parse(post['node']['date']), :domain => 'lucas.house.gov'}
      end
      results
    end

    def self.jasonsmith
      results = []
      url = "https://jasonsmith.house.gov/newsroom/default.aspx"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//article").each do |row|
        results << {:source => url, :url => "https://jasonsmith.house.gov" + row.css("h2 a").first['href'], :title => row.css("h2").text.strip, :date => Date.parse(row.css('time').text), :domain => 'jasonsmith.house.gov' }
      end
      results
    end

    def self.bucshon(page=1)
      results = []
      url = "https://bucshon.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//article").each do |row|
        results << {:source => url, :url => "https://bucshon.house.gov" + row.css("h2 a").first['href'], :title => row.css("h2").text.strip, :date => Date.parse(row.css('time').first['datetime']), :domain => 'bucshon.house.gov' }
      end
      results
    end

    def self.titus(page=1)
      results = []
      url = "https://titus.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//article").each do |row|
        results << {:source => url, :url => "https://titus.house.gov" + row.css("h2 a").first['href'], :title => row.css("h2").text.strip, :date => Date.parse(row.css('time').first['datetime']), :domain => 'titus.house.gov' }
      end
      results
    end

    def self.gosar(page=1)
      results = []
      url = "https://gosar.house.gov/news/email/default.aspx?Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("ul.UnorderedNewsList li").each do |row|
        results << {:source => url, :url => row.at_css('a')['href'], :title => row.at_css('b').text, :date => Date.parse(row.at_css('br').next.text.strip), :domain => 'gosar.house.gov' }
      end
      results

    end

    def self.jordan(page=1)
      results = []
      url = "https://jordan.house.gov/newsroom/documentquery.aspx?DocumentTypeID=1611&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('.UnorderedNewsList li').each do |row|
        results << {:source => url, :url => 'https://jordan.house.gov/newsroom/' + row.css('a').first['href'], :title => row.css('a').first.text.strip, :date => Date.parse(row.css('a').first.next.next.text.strip), :domain => 'jordan.house.gov' }
      end
      results
    end

    def self.wenstrup(page=1)
      results = []
      url = "https://wenstrup.house.gov/updates/documentquery.aspx?DocumentTypeID=2491&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//ul[@class='UnorderedNewsList']//article").each do |row|
        article_url = 'https://wenstrup.house.gov/updates/' + row.css("h2 a").first['href'].gsub('/news/','')
        results << {:source => url, :url => article_url, :title => row.css("h2").text.strip, :date => Date.parse(row.css('time').first['datetime']), :domain => 'wenstrup.house.gov' }
      end
      results
    end

    def self.schumer(page=1)
      results = []
      domain = 'www.schumer.senate.gov'
      url = "https://www.schumer.senate.gov/newsroom/press-releases/table?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = (doc/:table/:tr).select{|r| !r.children[3].nil?}
      rows.each do |row|
        results << {:source => url, :url => row.children[3].children[1]['href'].strip, :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text.strip), :domain => domain }
      end
      results
    end

    def self.bennet(page=1)
      results = []
      domain = 'www.bennet.senate.gov'
      url = "https://www.bennet.senate.gov/public/index.cfm/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      (doc/:article).each do |row|
        results << {:source => url, :url => 'https://www.bennet.senate.gov' + row['data-href'], :title => row.css('h1').text, :date => Date.parse(row.search('.date').text), :domain => domain }
      end
      results
    end

    def self.cantwell(page=1)
      results = []
      domain = 'www.cantwell.senate.gov'
      url = "https://www.cantwell.senate.gov/themes/cantwell/templates/partials/includes/resultset.cfm?view=press_quick_vw&columns=title,date,friendly_url&order_cols=date&order_dirs=DESC&current_page=#{page}&results_per_page=100&restrict_keys=type&restrict_vals=press_release&restrict_ops="
      doc = open_html(url)
      return if doc.nil?
      doc.css('table tr').each do |row|
        results << {:source => url, :url => row.children[3].children[1]['href'], :title => row.children[3].children[1].text.strip, :date => Date.strptime(row.children[1].text.strip, "%m.%d.%y"), :domain => domain }
      end
      results
    end

    def self.wyden(page=1)
      results = []
      url = "https://www.wyden.senate.gov/news/press-releases?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      doc.css('#newscontent h2').each do |row|
        results << { :source => url,
                     :url => "https://www.wyden.senate.gov/" + row.css('a').first['href'],
                     :title => row.text.strip,
                     :date => Date.parse(row.previous.previous.text),
                     :domain => 'www.wyden.senate.gov' }
      end
      results
    end

    def self.house_drupal(domains=[], page=0)
      results = []
      if domains.empty?
        domains = [
          "wild.house.gov",
          "harder.house.gov",
          "davids.house.gov",
          "eshoo.house.gov"
        ]
      end

      domains.each do |domain|
        puts domain
        url = "https://#{domain}/media/press-releases?page=#{page}"
        doc = Statement::Scraper.open_html(url)
        return if doc.nil?
        doc.css(".view-content .views-row").first(10).each do |row|
          results << {:source => url, :url => "https://#{domain}" + row.css('h3').first.children.first['href'], :title => row.css('h3').first.children.first.text.strip, :date => Date.parse(row.css(".views-field .field-content")[1].text), :domain => domain }
        end
      end
      results
    end

    def self.lamborn(page=0)
      results = []
      domain = 'lamborn.house.gov'
      url = "https://lamborn.house.gov/media/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").first(10).each do |row|
        begin
          results << {:source => url, :url => "https://#{domain}" + row.css('h3').first.children.first['href'], :title => row.css('h3').first.children.first.text.strip, :date => Date.parse(row.css(".views-field .field-content")[1].text), :domain => domain }
        rescue
          next
        end
      end
      results
    end

    def self.porter(page=1)
      results = []
      domain = 'porter.house.gov'
      url = "https://porter.house.gov/news/documentquery.aspx?Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//article").each do |row|
        results << {:source => url, :url => "https://porter.house.gov" + row.css("h2 a").first['href'], :title => row.css("h2").text.strip, :date => Date.parse(row.css('time').text), :domain => domain }
      end
      results
    end

    def self.tlaib
      results = []
      url = "https://tlaib.house.gov/resources/press"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      json = JSON.load(doc.at_css('[id="__NEXT_DATA__"]').text)
      posts = json['props']['pageProps']['dehydratedState']['queries'][12]['state']['data']['posts']['edges']
      posts.each do |post|
        results << { :source => url, :url => post['node']['link'], :title => post['node']['title'], :date => Date.parse(post['node']['date']), :domain => 'tlaib.house.gov'}
      end
      results
    end

    def self.vandrew(page=0)
      results = []
      domain = 'vandrew.house.gov'
      url = "https://vandrew.house.gov/media/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").first(10).each do |row|
        begin
          results << {:source => url, :url => "https://#{domain}" + row.css('h3').first.children.first['href'], :title => row.css('h3').first.children.first.text.strip, :date => Date.parse(row.css(".views-field .field-content")[1].text), :domain => domain }
        rescue
          next
        end
      end
      results
    end

    def self.media_digest(urls=[], page=1)
      if urls.empty?
        urls = [
          "https://himes.house.gov/press-releases",
          "https://austinscott.house.gov/press-releases",
          "https://gooden.house.gov/press-releases",
          "https://hayes.house.gov/press-releases",
          "https://desjarlais.house.gov/media-center"
        ]
      end
      results = []
      urls.each do |url|
        puts url
        uri = URI(url)
        source_url = "#{url}?page=#{page}"
        domain =  URI.parse(source_url).host
        doc = open_html(source_url)
        return if doc.nil?
        doc.css("div.media-digest-body").each do |row|
          results << { :source => url, :url => "https://"+domain+row.css("a").attr('href').value, :title => row.css("div.post-media-digest-title").text, :date => Date.parse(row.css("div.post-media-digest-date").text), :domain => domain}
        end
      end
      results
    end

    def self.recordlist(urls=[], page=1)
      if urls.empty?
        urls = [
          "https://kaygranger.house.gov/press-releases",
          "https://emmer.house.gov/press-releases",
          "https://fitzpatrick.house.gov/press-releases",
          "https://lynch.house.gov/press-releases",
          "https://crenshaw.house.gov/press-releases",
          "https://stanton.house.gov/press-releases",
          "https://davidson.house.gov/press-releases",
          "https://dean.house.gov/press-releases",
          "https://raskin.house.gov/press-releases",
          "https://lahood.house.gov/press-releases",
          "https://turner.house.gov/press-releases",
          "https://stefanik.house.gov/press-releases",
          "https://bost.house.gov/press-releases",
          "https://comer.house.gov/press-release",
          "https://fischbach.house.gov/press-releases",
          "https://bowman.house.gov/press-releases",
          "https://sessions.house.gov/press-releases",
          "https://vanduyne.house.gov/press-releases",
          "https://finstad.house.gov/press-releases",
          "https://mcclain.house.gov/press-releases",
          "https://scottpeters.house.gov/press-releases"
        ]
      end
      results = []
      urls.each do |url|
        puts url
        uri = URI(url)
        source_url = "#{url}?page=#{page}"
        domain =  URI.parse(source_url).host
        doc = open_html(source_url)
        return if doc.nil?
        doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
          next if row.children[3].text.strip == 'Title'
          results << { :source => url, :url => "https://"+domain+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => domain }
        end
      end
      results
    end

    def self.barr(year=Date.today.year)
      results = []
      url = "https://barr.house.gov/press-releases?MonthDisplay=0&YearDisplay=#{year}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      return if doc.xpath("//table[@class='table recordList']//tr").empty?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[3].text.strip == 'Title'
        results << { :source => url, :url => "https://barr.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "barr.house.gov" }
      end
      results
    end

    def self.trone(page=1)
      results = []
      domain = "trone.house.gov"
      url = "https://trone.house.gov/category/congress_press_release/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.item").each do |row|
        results << {:source => url, :url => row.css('a').first['href'], :title => row.css('h2').text, :date => Date.parse(row.css("span.date").first.text), :domain => domain }
      end
      results
    end

    def self.schweikert(page=1)
      results = []
      domain = "schweikert.house.gov"
      url = "https://schweikert.house.gov/category/congress_press_release/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.item").each do |row|
        results << {:source => url, :url => row.css('a').first['href'], :title => row.css('h2').text, :date => Date.parse(row.css("span.date").first.text), :domain => domain }
      end
      results
    end

    def self.aguilar(page=1)
      results = []
      domain = "aguilar.house.gov"
      url = "https://aguilar.house.gov/category/congress_press_release/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.item").each do |row|
        results << {:source => url, :url => row.css('a').first['href'], :title => row.css('h2').text.strip, :date => Date.parse(row.css('span.date').text), :domain => domain }
      end
      results
    end

    def self.mooney(page=1)
      results = []
      domain = "mooney.house.gov"
      url = "https://mooney.house.gov/category/press-releases/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << {:source => url, :url => "https://mooney.house.gov"+ row.css('a').first['href'], :title => row.css('span.screen-reader-text').text, :date => Date.parse(row.css("p").at("span")['datetime']), :domain => domain }
      end
      results
    end

    def self.houlahan(page=1)
      results = []
      domain = 'houlahan.house.gov'
      url = "https://houlahan.house.gov/press/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << {:source => url, :url => "https://houlahan.house.gov"+ row.at_css('a')['href'], :title => row.at_css('a').text, :date => Date.parse(row.css("span.date").text + ", 2023"), :domain => domain }
      end
      results
    end

    def self.mcgovern(page=1)
      results = []
      domain = 'mcgovern.house.gov'
      url = "https://mcgovern.house.gov/news/documentquery.aspx?DocumentTypeID=2472&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << {:source => url, :url => "https://mcgovern.house.gov"+ row.at_css('a')['href'], :title => row.at_css('a').text, :date => row.at_css("time")['datetime'], :domain => domain }
      end
      results
    end

    def self.article_newsblocker(domains=[], page=1)
      results = []
      if domains.empty?
        domains = [
          "bluntrochester.house.gov",
          "sarajacobs.house.gov",
          "balderson.house.gov",
          "case.house.gov",
          "mikegarcia.house.gov",
          "donalds.house.gov",
          "clyde.house.gov",
          "rosendale.house.gov",
          "pfluger.house.gov",
          "jackson.house.gov",
          "peltola.house.gov",
          "nickel.house.gov",
          "ezell.house.gov",
          "pettersen.house.gov",
          "duarte.house.gov",
          "brecheen.house.gov",
          "carter.house.gov",
          "molinaro.house.gov",
          "stewart.house.gov",
          "baird.house.gov",
          "greene.house.gov",
          "frankel.house.gov",
          "loudermilk.house.gov",
          "wilson.house.gov",
          "lawler.house.gov",
          "balint.house.gov"
        ]
      end
      domains.each do |domain|
        puts domain
        url = "https://#{domain}/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
        doc = Statement::Scraper.open_html(url)
        return if doc.nil?
        doc.css("article").each do |row|
          results << {:source => url, :url => "https://#{domain}/news/"+ row.at_css('a')['href'], :title => row.at_css('a').text, :date => Date.parse(row.at_css("time")['datetime']), :domain => domain }
        end
      end
      results
    end

    def self.scanlon(page=1)
      results = []
      domain = 'scanlon.house.gov'
      url = "https://scanlon.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << {:source => url, :url => "https://scanlon.house.gov/news/"+ row.at_css('a')['href'], :title => row.at_css('a').text.strip, :date => Date.parse(row.css("time").text), :domain => domain }
      end
      results
    end

    def self.grijalva(page=1)
      results = []
      domain = "grijalva.house.gov"
      url = "https://grijalva.house.gov/category/congress_press_release/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.item").each do |row|
        results << {:source => url, :url => row.at("a")['href'], :title => row.css('div.info-title').text, :date => Date.parse(row.css('div.info-date').text), :domain => domain }
      end
      results
    end

    def self.bergman(page=1)
      results = []
      domain = "bergman.house.gov"
      url = "https://bergman.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << {:source => url, :url => 'https://bergman.house.gov/news/' + row.at_css('h2 a')['href'], :title => row.at_css('h2').text, :date => Date.parse(row.css('time').text), :domain => domain }
      end
      results
    end

    def self.keating
      results = []
      domain = "keating.house.gov"
      source_url = "https://#{domain}/index.php?option=com_content&view=category&id=14&Itemid=13"
      doc = open_html(source_url)
      return if doc.nil?
      doc.css("div.entry-header").each do |row|
        url = 'https://' + domain + row.children[3].children[1]['href']
        title = row.children[3].children[1].text.strip
        results << { :source => source_url, :url => url, :title => title, :date => Date.parse(row.children[1].children[3].text.strip), :domain => domain}
      end
      results
    end

    def self.drupal(urls=[], page=0)
      if urls.empty?
        urls = [
            "https://sherman.house.gov/media-center/press-releases",
            "https://quigley.house.gov/media-center/press-releases",
            "https://waters.house.gov/media-center/press-releases",
            "https://swalwell.house.gov/media-center/press-releases",
            "https://keating.house.gov/media-center/press-releases",
            "https://khanna.house.gov/media/press-releases",
            "https://panetta.house.gov/media/press-releases",
            "https://schneider.house.gov/media/press-releases",
            "https://dankildee.house.gov/media/press-releases",
            "https://lofgren.house.gov/media/press-releases",
            "https://sylviagarcia.house.gov/media/press-releases",
            "https://susielee.house.gov/media/press-releases",
            "https://danbishop.house.gov/media/press-releases"
        ]
      end

      results = []

      urls.each do |url|
        puts url
        uri = URI(url)
        source_url = "#{url}?page=#{page}"

        domain =  URI.parse(source_url).host
        doc = open_html(source_url)
        return if doc.nil?

        if doc.css("#region-content .views-row").size == 0
          puts url
        end

        doc.css("#region-content .views-row").each do |row|
            title_anchor = row.css("h3 a")
            title = title_anchor.text.strip
            release_url = "#{uri.scheme}://#{domain + title_anchor.attr('href')}"
            raw_date = row.css(".views-field-created").text
            results << { :source => source_url,
                         :url => release_url,
                         :title => title,
                         :date => begin Date.parse(raw_date) rescue nil end,
                         :domain => domain }
        end
      end
      results
    end

    def self.senate_drupal_newscontent(urls=[], page=1)
      results = []
      if urls.empty?
        urls = [
          "https://www.young.senate.gov/newsroom/press-releases",
          "https://huffman.house.gov/media-center/press-releases",
          "https://castro.house.gov/media-center/press-releases",
          "https://cardenas.house.gov/media-center/press-releases",
          "https://mikelevin.house.gov/media/press-releases",
          "https://watsoncoleman.house.gov/newsroom/press-releases",
          "https://bush.house.gov/media/press-releases",
          "https://auchincloss.house.gov/media/press-releases",
          "https://vargas.house.gov/media-center/press-releases",
          "https://correa.house.gov/press"
        ]
      end
      urls.each do |url|
        puts url
        uri = URI(url)
        source_url = "#{url}?PageNum_rs=#{page}"

        domain =  URI.parse(source_url).host
        doc = Statement::Scraper.open_html(source_url)
        return if doc.nil?
        doc.css('#newscontent h2').each do |row|
          results << { :source => url,
                       :url => "https://#{domain}" + row.css('a').first['href'],
                       :title => row.text.strip,
                       :date => Date.parse(row.previous.previous.text),
                       :domain => domain }
        end
      end
      results
    end

    def self.senate_wordpress(urls=[], page=1)
      results = []
      if urls.empty?
        urls = [
          "https://www.kelly.senate.gov/media/press-releases/",
          "https://www.hickenlooper.senate.gov/media/press-releases/",
          "https://www.sanders.senate.gov/media/press-releases/",
          "https://www.marshall.senate.gov/media/press-releases/"
        ]
      end
      urls.each do |url|
        uri = URI(url)
        source_url = "#{url}/#{page}"
        domain =  URI.parse(source_url).host
        doc = Statement::Scraper.open_html(source_url)
        return if doc.nil?
        doc.css('.elementor-post__text').each do |row|
          results << { :source => url,
                       :url => row.css('a').first['href'],
                       :title => row.css('h2').text.strip,
                       :date => Date.parse(row.css('.elementor-post-date').text.strip),
                       :domain => domain }
        end
      end
      results
    end

    def self.duckworth(page=1)
      results = []
      url = "https://www.duckworth.senate.gov/news/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('#newscontent h2').each do |row|
        results << { :source => url,
                     :url => "https://www.duckworth.senate.gov/" + row.css('a').first['href'],
                     :title => row.text.strip,
                     :date => Date.parse(row.previous.previous.text),
                     :domain => 'www.duckworth.senate.gov' }
      end
      results
    end

    def self.cortezmasto(page=1)
      results = []
      url = "https://www.cortezmasto.senate.gov/news/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('#press h2').each do |row|
        results << { :source => url,
                     :url => "https://www.cortezmasto.senate.gov/" + row.css('a').first['href'],
                     :title => row.text.strip,
                     :date => Date.parse(row.previous.previous.text),
                     :domain => 'www.cortezmasto.senate.gov' }
      end
      results
    end

    def self.hassan(page=1)
      results = []
      url = "https://www.hassan.senate.gov/news/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.ArticleBlock").each do |row|
        results << { :source => url,
                     :url => row.css('a').first['href'],
                     :title => row.css('h2').text,
                     :date => Date.parse(row.css('time').first.attributes['datetime'].value),
                     :domain => 'www.hassan.senate.gov' }
      end
      results
    end

    def self.baldwin(page=1)
      results = []
      url = "https://www.baldwin.senate.gov/news/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.ArticleBlock").each do |row|
        results << { :source => url,
                     :url => row.css('a').first['href'],
                     :title => row.css('h2').text,
                     :date => Date.parse(row.css('p').text.gsub('.','/')),
                     :domain => 'www.baldwin.senate.gov' }
      end
      results
    end

    def self.cruz(page=1)
      results = []
      url = "https://www.cruz.senate.gov/newsroom/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("li.PageList__item").each do |row|
        results << { :source => url,
                     :url => row.css('a').first['href'],
                     :title => row.css('h2').text,
                     :date => Date.parse(row.css('p').text.gsub('.','/')),
                     :domain => 'www.cruz.senate.gov' }
      end
      results
    end

    def self.schatz(page=1)
      results = []
      url = "https://www.schatz.senate.gov/news/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.ArticleBlock").each do |row|
        results << { :source => url,
                     :url => row.css('a').first['href'],
                     :title => row.css('h2').text,
                     :date => Date.parse(row.css('p').text.gsub('.','/')),
                     :domain => 'www.schatz.senate.gov' }
      end
      results
    end

    def self.padilla(page=1)
      results = []
      url = "https://www.padilla.senate.gov/newsroom/press-releases/?jsf=jet-engine:press-list&pagenum=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('div.jet-listing-grid__item').each do |row|
        results << { :source => url,
                     :url => row.css('a').first['href'],
                     :title => row.css('a').first.text.strip,
                     :date => Date.parse(row.css('li').first.text.strip),
                     :domain => 'www.padilla.senate.gov' }
      end
      results
    end

    def self.lujan(page=1)
      results = []
      url = "https://www.lujan.senate.gov/newsroom/press-releases/?jsf=jet-engine:press-list&pagenum=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('div.jet-listing-grid__item').each do |row|
        results << { :source => url,
                     :url => row.css('a').first['href'],
                     :title => row.css('a').first.text.strip,
                     :date => Date.parse(row.css('li').first.text.strip),
                     :domain => 'www.lujan.senate.gov' }
      end
      results
    end

    def self.manchin(page=1)
      results = []
      url = "https://www.manchin.senate.gov/newsroom/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2")[1..-1].each do |row|
        results << { :source => url,
                     :url => "https://www.manchin.senate.gov" + row.css('a').first['href'],
                     :title => row.text.strip,
                     :date => Date.parse(row.previous.previous.text),
                     :domain => 'www.manchin.senate.gov' }
      end
      results
    end

    def self.timscott(page=1)
      results = []
      url = "https://www.scott.senate.gov/media-center/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2")[0..-1].each do |row|
        results << { :source => url,
                     :url => "https://www.scott.senate.gov" + row.css('a').first['href'],
                     :title => row.text.strip,
                     :date => Date.parse(row.next.next.text),
                     :domain => 'www.scott.senate.gov' }
      end
      results
    end

    def self.reschenthaler(page=1)
      results = []
      url = "https://reschenthaler.house.gov/media/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2")[0..-1].each do |row|
        results << { :source => url,
                     :url => "https://reschenthaler.house.gov" + row.css('a').first['href'],
                     :title => row.text.strip,
                     :date => Date.parse(row.previous.previous.text),
                     :domain => 'reschenthaler.house.gov' }
      end
      results
    end

    def self.paul(page=0)
      results = []
      url = "https://www.paul.senate.gov/news/press-release?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".views-row").each do |row|
          results << { :source => url,
                       :url => "https://www.paul.senate.gov" + row.css('a').first['href'],
                       :title => row.css('h2').text.strip,
                       :date => Date.parse(row.css(".pub-date").text),
                       :domain => 'www.paul.senate.gov' }
      end
      results
    end

    def self.rickscott(page=1)
      results = []
      url = "https://www.rickscott.senate.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css(".element")
      rows.each do |row|
        year = Date.today.month == 1 ? Date.today.year-1 : Date.today.year
        results << { :source => url, :url => row.css('a').first['href'], :title => row.css('.element-title').text.strip, :date => Date.strptime(row.css('.element-date').text + " "+ year.to_s, "%b %d %Y"), :domain => "www.rickscott.senate.gov" }
      end
      results
    end

    def self.hydesmith(page=0)
      results = []
      url = "https://www.hydesmith.senate.gov/news-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
          results << { :source => url,
                       :url => "https://www.hydesmith.senate.gov" + row.css('a').first['href'],
                       :title => row.css('h2').text.strip,
                       :date => Date.parse(row.css('time').text),
                       :domain => 'www.hydesmith.senate.gov' }
      end
      results
    end

    def self.rosen(page=1)
      results = []
      url = "https://www.rosen.senate.gov/category/press_release/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('article').each do |row|
        results << { :source => url, :url => row.css("h2 a").first['href'], :title => row.css("h2").text.strip, :date => Date.parse(row.css("span").text.strip), :domain => "www.rosen.senate.gov" }
      end
      results
    end

    def self.pressley(page=1)
      results = []
      url = "https://pressley.house.gov/category/press-releases/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('a.post').each do |row|
        results << { :source => url, :url => row['href'], :title => row.css("p")[1].text.strip, :date => Date.parse(row.css("p")[0].text.strip), :domain => "pressley.house.gov" }
      end
      results
    end

    def self.capito(page=1)
      results = []
      url = "https://www.capito.senate.gov/news/press-releases?pagenum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".ArticleBlock").each do |row|
          results << { :source => url,
                       :url => row.css('a').first['href'],
                       :title => row.css('a').text.strip,
                       :date => Date.parse(row.css('p').text),
                       :domain => 'www.capito.senate.gov' }
      end
      results
    end

    def self.shaheen(page=1)
      results = []
      url = "https://www.shaheen.senate.gov/news/press?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          results << { :source => url,
                       :url => "https://www.shaheen.senate.gov/" + row.css('a').first['href'],
                       :title => row.text.strip,
                       :date => Date.parse(row.previous.previous.text),
                       :domain => 'www.shaheen.senate.gov' }
      end
      results
    end

    def self.barbaralee(page=1)
      results = []
      url = "https://lee.house.gov/news/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          title = row.text.strip
          release_url = "https://lee.house.gov" + row.css('a').first['href']
          results << { :source => url,
                       :url => release_url,
                       :title => title,
                       :date => begin Date.parse(row.previous.previous.text) rescue nil end,
                       :domain => 'lee.house.gov'}
      end
      results
    end

    def self.senate_drupal_new(urls=[], page=0)
      if urls.empty?
        urls = [
          "https://www.smith.senate.gov/press-releases",
          "https://www.braun.senate.gov/press-releases",
          "https://www.sinema.senate.gov/press-releases",
          "https://www.hawley.senate.gov/press-releases"
        ]
      end
      results = []
      urls.each do |url|
        puts url
        uri = URI(url)
        source_url = "#{url}?page=#{page}"
        domain =  URI.parse(source_url).host
        doc = Statement::Scraper.open_html(source_url)
        doc.css('.views-row').each do |row|
          if row.css('h2 a').size == 1
            results << {:source => url, :url => "https://#{domain}" + row.css('h2 a').first['href'], :title => row.css('h2').text.strip, :date => Date.parse(row.css("time").text), :domain => domain}
          end
        end
      end
      results
    end

    def self.senate_drupal(urls=[], page=1)
      if urls.empty?
        urls = [
          "https://www.durbin.senate.gov/newsroom/press-releases",
          "https://www.daines.senate.gov/news/press-releases",
          "https://www.hoeven.senate.gov/news/news-releases",
          "https://www.stabenow.senate.gov/news",
          "https://www.murkowski.senate.gov/press/press-releases",
          "https://www.lankford.senate.gov/news/press-releases",
          "https://www.republicanleader.senate.gov/newsroom/press-releases",
          "https://www.vanhollen.senate.gov/news/press-releases"
        ]
      end

      results = []

      urls.each do |url|
        puts url
        uri = URI(url)
        source_url = "#{url}?PageNum_rs=#{page}"
        domain =  URI.parse(source_url).host
        doc = Statement::Scraper.open_html(source_url)
        return if doc.nil?

        doc.css("#newscontent h2").each do |row|
            title = row.text.strip
            release_url = "#{uri.scheme}://#{domain + row.css('a').first['href']}"
            raw_date = row.previous.previous.text
            if domain == 'www.tomudall.senate.gov' or domain == "www.vanhollen.senate.gov" or domain == "www.warren.senate.gov"
              date = Date.parse(raw_date)
            elsif url == 'https://www.republicanleader.senate.gov/newsroom/press-releases'
              domain = 'mcconnell.senate.gov'
              date = Date.parse(row.previous.previous.text.gsub('.','/'))
              release_url = release_url.gsub('mcconnell.senate.gov','www.republicanleader.senate.gov')
            else
              date = begin Date.strptime(raw_date, "%m.%d.%y") rescue nil end
            end
            results << { :source => source_url,
                         :url => release_url,
                         :title => title,
                         :date => date,
                         :domain => domain }
        end
      end
      results

    end
  end

end
