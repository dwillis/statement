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
      if Date.today.month == 1
        Date.today.year-1
      else
        Date.today.year
      end
    end

    def self.current_month
      Date.today.month
    end

    def self.member_methods
      [:klobuchar, :crapo, :burr, :trentkelly, :kilmer, :cardin, :heinrich, :halrogers, :bucshon, :document_query_new, :fulcher, :gardner, :costa, :jordan, :watkins, :barr, :lamborn,
      :wenstrup, :robbishop, :tomrice, :bwcoleman, :manchin, :harris, :timscott, :banks, :senate_drupal_newscontent, :shaheen, :paul, :house_drupal, :pence, :tlaib, :hayes, :markgreen,
      :inhofe, :document_query, :fischer, :clark, :schiff, :barbaralee, :cantwell, :wyden, :cornyn, :marchant, :connolly, :mast, :hassan, :yarmuth, :adamsmith, :vandrew, :rickscott,
      :welch, :schumer, :cassidy, :lowey, :mcmorris, :takano, :lacyclay, :gillibrand, :walorski, :garypeters, :webster, :cortezmasto, :hydesmith, :rouzer, :mcbath, :coons, :norman,
      :grassley, :bennet, :drupal, :durbin, :senate_drupal, :senate_drupal_new, :rounds, :sullivan, :kennedy, :duckworth, :dougjones, :angusking, :correa, :blunt, :tillis, :emmer,
      :porter, :lawson, :speier, :neguse, :jasonsmith, :vargas, :moulton]
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
      results = [klobuchar(year), kilmer, lacyclay, sullivan, halrogers, shaheen, timscott, wenstrup, bucshon, angusking, document_query_new, fulcher, gardner, jordan, watkins, lamborn,
        document_query([], page=1), document_query([], page=2), crapo, grassley(page=0), burr, cassidy, cantwell, cornyn, kind, senate_drupal_new, bwcoleman, dougjones, tlaib, markgreen,
        inhofe, fischer, clark, welch, trentkelly, barbaralee, cardin, wyden, webster, mast, hassan, cortezmasto, manchin, robbishop, yarmuth, costa, house_drupal, adamsmith, norman,
        schumer, lowey, mcmorris, schiff, takano, heinrich, walorski, marchant, garypeters, rounds, connolly, paul, banks, harris, tomrice, hydesmith, rouzer, correa, pence, rickscott,
        bennet(page=1), drupal, durbin(page=1), gillibrand, kennedy, duckworth, senate_drupal_newscontent, senate_drupal, vandrew, mcbath, blunt, tillis, coons, hayes, barr, emmer, porter,
        lawson, speier, neguse, jasonsmith, vargas, moulton].flatten
      results = results.compact
      Utils.remove_generic_urls!(results)
    end

    def self.backfill_from_scrapers
      results = [document_query(page=3), cardin(page=2), cornyn(page=1), timscott(page=2), timscott(page=3),
        document_query(page=4), grassley(page=1), grassley(page=2), grassley(page=3), burr(page=2), burr(page=3), burr(page=4), cantwell(page=2),
        clark(year=2013), kilmer(page=2), kilmer(page=3), heinrich(page=2), kind(page=1), walorski(page=2), manchin(page=2), manchin(page=3),
        cassidy(page=2), cassidy(page=3), gillibrand(page=2), paul(page=1), paul(page=2), banks(page=2),
        olson(year=2013), schumer(page=2), schumer(page=3), poe(year=2015, month=2), lowey(page=1), wyden(page=2),
        lowey(page=2), lowey(page=3), mcmorris(page=2), mcmorris(page=3), schiff(page=2), schiff(page=3),
        takano(page=2), takano(page=3)].flatten
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
      doc.css('.list-item')[1..-1].each do |row|
        results << { :source => url, :url => "https://ethics.house.gov"+row.css('a').first['href'], :title => row.css('h4').text, :date => Date.parse(row.css(".date").text), :domain => "ethics.house.gov", :party => nil }
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

    ## special cases for members without RSS feeds

    def self.capuano
      results = []
      base_url = "http://capuano.house.gov/news/date.shtml"
      doc = open_html(base_url)
      return if doc.nil?
      doc.xpath("//p//a").select{|l| !l['href'].nil? and ['/st', '/pr'].any? {|w| l['href'].include?(w)}}[1..-5].each do |link|
        begin
          year = link['href'].split('/').first
          date = Date.parse(link.text.split(' ').first+'/'+year)
        rescue
          date = nil
        end
        results << { :source => base_url, :url => "http://capuano.house.gov/news/" + link['href'], :title => link.text.split(' ',2).last, :date => date, :domain => "www.house.gov/capuano/" }
      end
      return results[0..-5]
    end

    def self.marchant
      results = []
      url = "https://marchant.house.gov/wp-content/themes/marchant/ajax/newsroom.php"
      json = JSON.load(open(url).read)
      json['posts'].each do |post|
        results << { source: "https://marchant.house.gov/newsroom/?terms=", url: post['guid'], title: post['post_title'], date: Date.parse(post['post_modified']), domain: 'marchant.house.gov' }
      end
      results
    end

    def self.halrogers(page=1)
      results = []
      url = "https://halrogers.house.gov/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[3].text.strip == 'Title'
        results << { :source => url, :url => "https://halrogers.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "halrogers.house.gov" }
      end
      results
    end

    def self.fulcher
      results = []
      url = "https://fulcher.house.gov/press-releases"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[3].text.strip == 'Title'
        results << { :source => url, :url => "https://fulcher.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "fulcher.house.gov" }
      end
      results
    end

    def self.speier(page=1)
      results = []
      url = "https://speier.house.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[3].text.strip == 'Title'
        results << { :source => url, :url => "https://speier.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "speier.house.gov" }
      end
      results
    end

    def self.mcbath(page=1)
      results = []
      url = "https://mcbath.house.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[3].text.strip == 'Title'
        results << { :source => url, :url => "https://mcbath.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "mcbath.house.gov" }
      end
      results
    end

    def self.markgreen(page=1)
      results = []
      url = "https://markgreen.house.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[3].text.strip == 'Title'
        results << { :source => url, :url => "https://markgreen.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "markgreen.house.gov" }
      end
      results
    end

    def self.tomrice(page=1)
      results = []
      url = "https://rice.house.gov/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[3].text.strip == 'Title'
        results << { :source => url, :url => "https://rice.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "rice.house.gov" }
      end
      results
    end

    def self.adamsmith(page=1)
      results = []
      url = "https://adamsmith.house.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[3].text.strip == 'Title'
        results << { :source => url, :url => "https://adamsmith.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "adamsmith.house.gov" }
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

    def self.mast
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
        elsif domain == 'www.enzi.senate.gov'
          if not month
            url = "https://#{domain}/public/index.cfm/news-releases"
          else
            url = "https://#{domain}/public/index.cfm/news-releases?YearDisplay=#{year}&MonthDisplay=#{month}&page=1"
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

    def self.mcmorris(page=1)
      results = []
      url = "https://mcmorris.house.gov/issues/page/#{page}/?tax=types&term=news_releases"
      doc = open_html(url)
      return if doc.nil?
      doc.css(".feed-result").each do |row|
        results << { :source => url, :url => row.children[3].children[3].children.first['href'], :title => row.children[3].children[3].children.first.text.strip, :date => Date.parse(row.children[3].children[1].text), :domain => "mcmorris.house.gov" }
      end
      results
    end

    def self.klobuchar(year=current_year, month=0, page=1)
      results = []
      url = "https://www.klobuchar.senate.gov/public/index.cfm/news-releases?MonthDisplay=#{month}&YearDisplay=#{year}&page=#{page}"
      doc = open_html(url)
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

    def self.coons(page=1)
      results = []
      url = "https://www.coons.senate.gov/news/press-releases?pagenum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".ArticleBlock").each do |row|
        results << { :source => url, :url => row.css('a').first['href'], :title => row.css('h3').text.strip, :date => Date.parse(row.css('.ArticleBlock__date').text), :domain => "www.coons.senate.gov" }
      end
      results
    end

    def self.schiff(page=1)
      results = []
      url = "https://schiff.house.gov/news/press-releases?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      rows = doc.css("#press").first.css('h2')
      rows.each do |row|
        results << { :source => url, :url => "https://schiff.house.gov" + row.children.first['href'], :title => row.children.last.text.strip, :date => Date.strptime(row.previous.previous.text, "%m.%d.%y"), :domain => "schiff.house.gov" }
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
        results << { :source => url, :url => "https://moulton.house.gov" + row.css('a')[0]['href'], :title => row.children.last.text.strip, :date => Date.parse(row.previous.previous.text), :domain => "moulton.house.gov" }
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
        results << { :source => url, :url => "https://kilmer.house.gov" + row.children.first['href'], :title => row.children.last.text.strip, :date => Date.strptime(row.previous.previous.text, "%m.%d.%y"), :domain => "kilmer.house.gov" }
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
        results << { :source => url, :url => "https://takano.house.gov" + row.children.first['href'], :title => row.children.last.text.strip, :date => Date.strptime(row.previous.previous.text, "%m.%d.%y"), :domain => "takano.house.gov" }
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

    def self.burr(page=1)
      results = []
      url = "https://www.burr.senate.gov/press/releases?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      rows = doc.css("#press").first.css('h2')
      rows.each do |row|
        results << { :source => url, :url => "https://www.burr.senate.gov" + row.children.first['href'], :title => row.children.last.text.strip, :date => Date.strptime(row.previous.previous.text, "%m.%d.%y"), :domain => "burr.senate.gov" }
      end
      results
    end

    def self.cassidy(page=1)
      results = []
      url = "https://www.cassidy.senate.gov/newsroom/press-releases?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      rows = doc.css("#press").first.css('h2')
      rows.each do |row|
        results << { :source => url, :url => "https://www.cassidy.senate.gov" + row.children.first['href'], :title => row.children.last.text.strip, :date => Date.strptime(row.previous.previous.text, "%m.%d.%y"), :domain => "www.cassidy.senate.gov" }
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
      doc.css("#newscontent h2").each do |row|
          results << { :source => url,
                       :url => "https://www.crapo.senate.gov/" + row.css('a').first['href'],
                       :title => row.text.strip,
                       :date => Date.parse(row.previous.previous.text),
                       :domain => 'www.crapo.senate.gov' }
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

    def self.grassley(page=0)
      results = []
      url = "https://www.grassley.senate.gov/news/news-releases?title=&tid=All&date[value]&page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='views-field views-field-field-release-date']").each do |row|
        results << { :source => url, :url => "https://www.grassley.senate.gov" + row.next.next.children[1].children[0]['href'], :title => row.next.next.text.strip, :date => Date.parse(row.text.strip), :domain => "www.grassley.senate.gov" }
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
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@id='press']//h2").each do |row|
        results << { :source => url, :url => "https://www.durbin.senate.gov"+row.children[0]['href'], :title => row.children[0].text.strip, :date => Date.parse(row.previous.previous.text.gsub(".","/")), :domain => 'www.durbin.senate.gov'}
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

    def self.walorski(page=nil)
      results = []
      url = "https://walorski.house.gov/news/press-releases/"
      url = url + "page/#{page}" if page
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='media-body']").each do |row|
        date = row.children[5].text.strip == '' ? nil : Date.parse(row.children[5].text)
        results << { source: url, url: row.children[1]['href'], title: row.children[3].text.strip, date: date, domain: "walorski.house.gov"}
      end
      results
    end

    def self.walorski(page=nil)
      results = []
      url = "https://walorski.house.gov/news/press-releases/"
      url = url + "page/#{page}" if page
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='media-body']").each do |row|
        date = row.children[5].text.strip == '' ? nil : Date.parse(row.children[5].text)
        results << { source: url, url: row.children[1]['href'], title: row.children[3].text.strip, date: date, domain: "walorski.house.gov"}
      end
      results
    end

    def self.welch(page=1)
      results = []
      domain = 'welch.house.gov'
      url = "https://welch.house.gov/media-center/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css("#region-content .views-row").each do |row|
        results << { :source => url, :url => "https://welch.house.gov"+row.css("h3 a").attr('href').value, :title => row.css("h3 a").text, :date => Date.parse(row.css(".views-field-created").text.strip), :domain => domain}
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

    def self.trentkelly(page=1)
      results = []
      domain = 'trentkelly.house.gov'
      url = "https://trentkelly.house.gov/newsroom/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='middlecopy']//li").each do |row|
        results << { :source => url, :url => "https://trentkelly.house.gov/news/" + row.children[1]['href'], :title => row.children[1].text.strip, :date => Date.parse(row.children[5].text.strip), :domain => domain }
      end
      results
    end

    def self.banks(page=1)
      results = []
      domain = 'banks.house.gov'
      url = "https://banks.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='middlecopy']//li").each do |row|
        results << { :source => url, :url => "https://banks.house.gov/news/" + row.children[1]['href'], :title => row.children[1].text.strip, :date => Date.parse(row.children[3].text.strip), :domain => domain }
      end
      results
    end

    def self.connolly(page=1)
      results = []
      domain = 'connolly.house.gov'
      url = "https://connolly.house.gov/news/documentquery.aspx?DocumentTypeID=1951&Page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='middlecopy']//li").each do |row|
        results << { :source => url, :url => "https://connolly.house.gov/news/" + row.children[1]['href'], :title => row.children[1].text.strip, :date => Date.parse(row.children[3].text.strip), :domain => domain }
      end
      results
    end

    def self.yarmuth
      results = []
      domain = 'yarmuth.house.gov'
      url = "https://yarmuth.house.gov/press/"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//li[@class='article']").each do |row|
        results << { :source => url, :url => "https://yarmuth.house.gov" + row.css('h3 a').first['href'], :title => row.css('h3 a').first.text.strip, :date => Date.parse(row.css('span')[1].text), :domain => domain }
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
          {"thornberry.house.gov" => 1776},
          {"palazzo.house.gov" => 2519},
          {"roe.house.gov" => 1532},
          {"perry.house.gov" => 2607},
          {"perry.house.gov" => 2608},
          {"rodneydavis.house.gov" => 2427},
          {"kevinbrady.house.gov" => 2657},
          {"loudermilk.house.gov" => 27},
          {"allen.house.gov" => 27},
          {"holding.house.gov" => 27},
          {"davidscott.house.gov" => 377},
          {"buddycarter.house.gov" => 27},
          {"grothman.house.gov" => 27},
          {"kathleenrice.house.gov" => 27},
          {"wittman.house.gov" => 2670},
          {"kinzinger.house.gov" => 2665},
          {"frankel.house.gov" => 27},
          {"conaway.house.gov" => 1279},
          {'chabot.house.gov' => 2508},
          {'hice.house.gov' => 27},
          {'tonko.house.gov' => 27},
          {'perlmutter.house.gov' => 27},
          {'francisrooney.house.gov' => 27},
          {'crist.house.gov' => 27},
          {'bergman.house.gov' => 27},
          {'stephaniemurphy.house.gov' => 27},
          {'gottheimer.house.gov' => 27},
          {'mcgovern.house.gov' => 2472},
          {'crawford.house.gov' => 2080},
          {'estes.house.gov' => 27},
          {'matsui.house.gov' => 27},
          {'carbajal.house.gov' => 27},
          {'budd.house.gov' => 27},
          {'delbene.house.gov' => 27},
          {'gosar.house.gov' => 27},
          {'wassermanschultz.house.gov' => 27},
          {'weber.house.gov' => 27},
          {'gwenmoore.house.gov' => 27},
          {'reed.house.gov' => 27},
          {'susandavis.house.gov' => 1782},
          {'meadows.house.gov' => 27},
          {'mckinley.house.gov' => 27},
          {'hill.house.gov' => 27}
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
          {'trahan.house.gov' => 27},
          {'vantaylor.house.gov' => 27},
          {'spanberger.house.gov' => 27},
          {'shalala.house.gov' => 27},
          {'maxrose.house.gov' => 27},
          {'houlahan.house.gov' => 27},
          {'hern.house.gov' => 27},
          {'fletcher.house.gov' => 27},
          {'crenshaw.house.gov' => 27},
          {'guthrie.house.gov' => 2381},
          {"pingree.house.gov" => 27},
          {"long.house.gov" => 27},
          {'perry.house.gov' => 2608},
          {"babin.house.gov" => 27},
          {'plaskett.house.gov' => 27},
          {'ratcliffe.house.gov' => 27},
          {'ferguson.house.gov' => 27},
          {'anthonybrown.house.gov' => 27},
          {"spano.house.gov"=>27},
          {"mucarsel-powell.house.gov"=>27},
          {"mikerogers.house.gov" => 27},
          {'nadler.house.gov' => 1753},
          {"anthonygonzalez.house.gov"=>27},
          {'debbiedingell.house.gov' => 27},
          {'gomez.house.gov' => 27},
          {"beyer.house.gov" => 27},
          {'baird.house.gov' => 27},
          {"waltz.house.gov" => 27},
          {'horn.house.gov' => 27},
          {'escobar.house.gov' => 27},
          {'mcadams.house.gov' => 27},
          {'wexton.house.gov' => 27}
        ]
      end
      domains.each do |domain|
        puts domain
        source_url = "https://"+domain.keys.first+"/news/documentquery.aspx?DocumentTypeID=#{domain.values.first}&Page=#{page}"
        doc = Statement::Scraper.open_html(source_url)
        return if doc.nil?
        doc.xpath("//article").each do |row|
          results << { :source => source_url, :url => "https://"+domain.keys.first+"/news/" + row.css("h3 a").first['href'], :title => row.css("h3").text.strip, :date => Date.parse(row.css('time').last.text), :domain => domain.keys.first }
        end
      end
      results
    end

    def self.norman(page=1)
      results = []
      url = "https://norman.house.gov/newsroom/default.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//article").each do |row|
        results << {:source => url, :url => "https://norman.house.gov" + row.css("h3 a").first['href'], :title => row.css("h3").text.strip, :date => Date.parse(row.css('time').first['datetime']), :domain => 'norman.house.gov' }
      end
      results
    end

    def self.jasonsmith
      results = []
      url = "https://jasonsmith.house.gov/newsroom/default.aspx"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//article").each do |row|
        results << {:source => url, :url => "https://jasonsmith.house.gov" + row.css("h3 a").first['href'], :title => row.css("h3").text.strip, :date => Date.parse(row.css('time').text), :domain => 'jasonsmith.house.gov' }
      end
      results
    end

    def self.bucshon(page=1)
      results = []
      url = "https://bucshon.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//article").each do |row|
        results << {:source => url, :url => "https://bucshon.house.gov" + row.css("h3 a").first['href'], :title => row.css("h3").text.strip, :date => Date.parse(row.css('time').first['datetime']), :domain => 'bucshon.house.gov' }
      end
      results
    end

    def self.bwcoleman(page=1)
      results = []
      url = "https://watsoncoleman.house.gov/newsroom/documentquery.aspx?DocumentTypeID=27&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//ul[@class='UnorderedNewsList']//a").each do |row|
        results << {:source => url, :url => 'https://watsoncoleman.house.gov/newsroom/' + row['href'], :title => row.css('li').children[1].text.strip, :date => Date.parse(row.css('li').children[3].text.strip), :domain => 'watsoncoleman.house.gov' }
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
      doc = open_html(url)
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
      doc = open_html(url)
      return if doc.nil?
      (doc/:article).each do |row|
        results << {:source => url, :url => 'https://www.bennet.senate.gov' + row['data-href'], :title => row.children[3].children[1].children[1].text.strip, :date => Date.parse(row.search('.date').text), :domain => domain }
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
          "calvert.house.gov",
          "morelle.house.gov",
          "wild.house.gov",
          "chuygarcia.house.gov",
          "stanton.house.gov",
          "harder.house.gov",
          "cox.house.gov",
          "cisneros.house.gov",
          "rouda.house.gov",
          "mikelevin.house.gov",
          "crow.house.gov",
          "steube.house.gov",
          "finkenauer.house.gov",
          "axne.house.gov",
          "casten.house.gov",
          "underwood.house.gov",
          "davids.house.gov",
          "pressley.house.gov",
          "trone.house.gov",
          "slotkin.house.gov",
          "andylevin.house.gov",
          "stevens.house.gov",
          "hagedorn.house.gov",
          "craig.house.gov",
          "phillips.house.gov",
          "omar.house.gov",
          "stauber.house.gov",
          "guest.house.gov",
          "armstrong.house.gov",
          "pappas.house.gov",
          "kim.house.gov",
          "wright.house.gov"
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

    def self.pence(page=0)
      results = []
      domain = 'pence.house.gov'
      url = "https://pence.house.gov/media/press-releases?page=#{page}"
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
        results << {:source => url, :url => "https://porter.house.gov" + row.css("h3 a").first['href'], :title => row.css("h3").text.strip, :date => Date.parse(row.css('time').text), :domain => domain }
      end
      results
    end

    def self.watkins(page=0)
      results = []
      domain = 'watkins.house.gov'
      url = "https://watkins.house.gov/media/press-releases?page=#{page}"
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

    def self.tlaib(page=0)
      results = []
      domain = 'tlaib.house.gov'
      url = "https://tlaib.house.gov/media/press-releases?page=#{page}"
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

    def self.hayes(page=0)
      results = []
      domain = 'hayes.house.gov'
      url = "https://hayes.house.gov/media/press-releases?page=#{page}"
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

    def self.rouzer(page=1)
      results = []
      url = "https://rouzer.house.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[3].text.strip == 'Title'
        results << { :source => url, :url => "https://rouzer.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "rouzer.house.gov" }
      end
      results
    end

    def self.emmer(page=1)
      results = []
      url = "https://emmer.house.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//table[@class='table recordList']//tr")[1..-1].each do |row|
        next if row.children[3].text.strip == 'Title'
        results << { :source => url, :url => "https://emmer.house.gov"+row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text), :domain => "emmer.house.gov" }
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

    def self.correa
      results = []
      url = "https://correa.house.gov/news"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        next if row.children[3].text.strip == 'Title'
        results << { :source => url, :url => "https://correa.house.gov"+row.css('a').first['href'], :title => row.css('a').first.text.strip, :date => Date.parse(row.css('.newsroom__date').text), :domain => "correa.house.gov" }
      end
      results
    end

    def self.aderholt(page=0)
      results = []
      domain = "aderholt.house.gov"
      url = "https://aderholt.house.gov/media-center/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").first(10).each do |row|
        results << {:source => url, :url => 'https://aderholt.house.gov' + row.css('h3').first.children.first['href'], :title => row.css('h3').first.children.first.text.strip, :date => Date.parse(row.css(".views-field .field-content")[1].text), :domain => domain }
      end
      results
    end

    def self.vargas(page=0)
      results = []
      domain = "vargas.house.gov"
      url = "https://vargas.house.gov/media-center/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").first(10).each do |row|
        results << {:source => url, :url => 'https://vargas.house.gov' + row.css('h3').first.children.first['href'], :title => row.css('h3').first.children.first.text.strip, :date => Date.parse(row.css(".views-field .field-content")[1].text), :domain => domain }
      end
      results
    end

    def self.lowey(page=0)
      results = []
      domain = "lowey.house.gov"
      url = "https://lowey.house.gov/media-center/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").first(10).each do |row|
        results << {:source => url, :url => 'https://lowey.house.gov' + row.css('h3').first.children.first['href'], :title => row.css('h3').first.children.first.text.strip, :date => Date.parse(row.css(".views-field .field-content")[1].text), :domain => domain }
      end
      results
    end

    def self.engel
      results = []
      domain = "engel.house.gov"
      url = "https://engel.house.gov/latest-news/showallitems/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".article").each do |row|
        results << {:source => url, :url => 'https://engel.house.gov' + row.css('h3 a').first['href'], :title => row.css('h3').first.text.strip, :date => Date.strptime(row.css(".sectiondate").text, "%m/%d/%y"), :domain => domain }
      end
      results
    end

    def self.robbishop(page=0)
      results = []
      domain = "robbishop.house.gov"
      url = "https://robbishop.house.gov/media/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").first(10).each do |row|
        results << {:source => url, :url => 'https://robbishop.house.gov' + row.css('h3').first.children.first['href'], :title => row.css('h3').first.children.first.text.strip, :date => Date.parse(row.css(".views-field .field-content")[1].text), :domain => domain }
      end
      results
    end

    def self.lacyclay(page=0)
      results = []
      domain = "lacyclay.house.gov"
      url = "https://lacyclay.house.gov/media-center/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").first(10).each do |row|
        results << {:source => url, :url => 'https://lacyclay.house.gov' + row.css('h3').first.children.first['href'], :title => row.css('h3').first.children.first.text.strip, :date => Date.parse(row.css(".views-field .field-content")[1].text), :domain => domain }
      end
      results
    end

    def self.kind(page=0)
      results = []
      domain = "kind.house.gov"
      url = "https://kind.house.gov/media-center/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").first(10).each do |row|
        results << {:source => url, :url => 'https://kind.house.gov' + row.css('h3').first.children.first['href'], :title => row.css('h3').first.children.first.text.strip, :date => Date.parse(row.css(".views-field .field-content")[1].text), :domain => domain }
      end
      results
    end

    def self.backfill_bilirakis(page=1)
      results = []
      domain = 'bilirakis.house.gov'
      url = "https://bilirakis.house.gov/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css("#region-content .views-row").each do |row|
          title_anchor = row.css("h3 a")
          title = title_anchor.text
          release_url = "https://#{domain + title_anchor.attr('href')}"
            raw_date = row.css(".views-field-created").text
          results << { :source => url,
                       :url => release_url,
                       :title => title,
                       :date => begin Date.parse(raw_date) rescue nil end,
                       :domain => domain }
      end
      results
    end

    def self.backfill_boustany(congress)
      results = []
      domain = 'boustany.house.gov'
      url = "https://boustany.house.gov/#{congress}th-congress/showallitems/"
      doc = open_html(url)
      return if doc.nil?
      (doc/:ul)[13].search(:li).each do |row|
        results << {:source => url, :url => 'https://boustany.house.gov' + row.children.search(:a)[0]['href'], :title => row.children.search(:a)[0].text, :date => Date.parse(row.children[5].text), :domain => domain }
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
            "https://mccaul.house.gov/media-center/press-releases",
            "https://mcnerney.house.gov/media-center/press-releases",
            "https://butterfield.house.gov/media-center/press-releases",
            "https://wilson.house.gov/media-center/press-releases",
            "https://bilirakis.house.gov/media/press-releases",
            "https://quigley.house.gov/media-center/press-releases",
            "https://sewell.house.gov/media-center/press-releases",
            "https://buchanan.house.gov/media-center/press-releases",
            "https://olson.house.gov/media-center/press-releases",
            "https://waters.house.gov/media-center/press-releases",
            "https://walden.house.gov/media-center/press-releases",
            "https://brooks.house.gov/media-center/news-releases",
            "https://swalwell.house.gov/media-center/press-releases",
            "https://keating.house.gov/media-center/press-releases",
            "https://blumenauer.house.gov/media-center/press-releases",
            "https://larson.house.gov/media-center/press-releases",
            "https://doggett.house.gov/media-center/press-releases",
            "https://kaptur.house.gov/media-center/press-releases",
            "https://neal.house.gov/press-releases",
            "https://vela.house.gov/media-center/press-releases",
            "https://khanna.house.gov/media/press-releases",
            "https://panetta.house.gov/media/press-releases",
            "https://demings.house.gov/media/press-releases",
            "https://mitchell.house.gov/media/press-releases",
            "https://schneider.house.gov/media/press-releases",
            "https://schweikert.house.gov/media-center/press-releases",
            "https://benniethompson.house.gov/media/press-releases",
            "https://austinscott.house.gov/media-center/press-releases",
            "https://radewagen.house.gov/media-center/press-releases",
            "https://delauro.house.gov/media-center/press-releases",
            "https://gabbard.house.gov/news",
            "https://lowenthal.house.gov/media/press-releases",
            "https://dankildee.house.gov/media/press-releases",
            "https://walberg.house.gov/media/press-releases",
            "https://smucker.house.gov/media/press-releases",
            "https://peteking.house.gov/media-center/statements",
            "https://gianforte.house.gov/media-center/press-releases",
            "https://price.house.gov/newsroom/press-releases",
            "https://lofgren.house.gov/media/press-releases",
            "https://lesko.house.gov/media",
            "https://allred.house.gov/media/press-releases",
            "https://brindisi.house.gov/media/press-releases",
            "https://burchett.house.gov/media/press-releases",
            "https://cline.house.gov/media/press-releases",
            "https://cunningham.house.gov/media/press-releases",
            "https://delgado.house.gov/media/press-releases",
            "https://dean.house.gov/media/press-releases",
            "https://sylviagarcia.house.gov/media/press-releases",
            "https://gooden.house.gov/media/press-releases",
            "https://golden.house.gov/media/press-releases",
            "https://haaland.house.gov/media/press-releases",
            "https://harder.house.gov/media/press-releases",
            "https://dustyjohnson.house.gov/media/press-releases",
            "https://johnjoyce.house.gov/media/press-releases",
            "https://susielee.house.gov/media/press-releases",
            "https://luria.house.gov/media/press-releases",
            "https://malinowski.house.gov/media/press-releases",
            "https://meuser.house.gov/media/press-releases",
            "https://miller.house.gov/media/press-releases",
            "https://ocasio-cortez.house.gov/media/press-releases",
            "https://reschenthaler.house.gov/media/press-releases",
            "https://riggleman.house.gov/media/press-releases",
            "https://johnrose.house.gov/media/press-releases",
            "https://roy.house.gov/media/press-releases",
            "https://rouda.house.gov/media/press-releases",
            "https://sannicolas.house.gov/media/press-releases",
            "https://sherrill.house.gov/media/press-releases",
            "https://steil.house.gov/media/press-releases",
            "https://schrier.house.gov/media/press-releases",
            "https://timmons.house.gov/media/press-releases",
            "https://torressmall.house.gov/media/press-releases",
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

        doc.css("#region-content .views-row").each do |row|
            title_anchor = row.css("h3 a")
            title = title_anchor.text
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
          "https://lujan.house.gov/media-center/press-releases",
          "https://kennedy.house.gov/newsroom/press-releases",
          "https://huffman.house.gov/media-center/press-releases"
        ]
      end
      urls.each do |url|
        uri = URI(url)
        source_url = "#{url}?PageNum_rs=#{page}"

        domain =  URI.parse(source_url).host
        doc = open_html(source_url)
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
      doc.css("#newscontent h2")[1..-1].each do |row|
        results << { :source => url,
                     :url => "https://www.hassan.senate.gov/" + row.css('a').first['href'],
                     :title => row.text.strip,
                     :date => Date.parse(row.previous.previous.text),
                     :domain => 'www.hassan.senate.gov' }
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

    def self.lawson(page=1)
      results = []
      url = "https://lawson.house.gov/media/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2")[0..-1].each do |row|
        results << { :source => url,
                     :url => "https://lawson.house.gov" + row.css('a').first['href'],
                     :title => row.text.strip,
                     :date => Date.parse(row.previous.previous.text),
                     :domain => 'lawson.house.gov' }
      end
      results
    end

    def self.neguse(page=1)
      results = []
      url = "https://neguse.house.gov/media/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2")[0..-1].each do |row|
        results << { :source => url,
                     :url => "https://neguse.house.gov" + row.css('a').first['href'],
                     :title => row.text.strip,
                     :date => Date.parse(row.previous.previous.text),
                     :domain => 'neguse.house.gov' }
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

    def self.rickscott(page=0)
      results = []
      url = "https://www.rickscott.senate.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".views-row").each do |row|
          results << { :source => url,
                       :url => "https://www.rickscott.senate.gov" + row.css('a').first['href'],
                       :title => row.children[0].text.strip,
                       :date => Date.parse(row.children.last.text),
                       :domain => 'www.rickscott.senate.gov' }
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

    def self.dougjones(page=1)
      results = []
      url = "https://www.jones.senate.gov/newsroom/press-releases?pagenum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".data-browser h2").each do |row|
          results << { :source => url,
                       :url => "https://www.jones.senate.gov" + row.css('a').first['href'],
                       :title => row.css('a').text.strip,
                       :date => Date.parse(row.next.next.text),
                       :domain => 'www.jones.senate.gov' }
      end
      results
    end

    def self.blunt(page=1)
      results = []
      url = "https://www.blunt.senate.gov/news/press-releases?pagenum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".data-browser h2").each do |row|
          results << { :source => url,
                       :url => "https://www.blunt.senate.gov" + row.css('a').first['href'],
                       :title => row.css('a').text.strip,
                       :date => Date.parse(row.next.next.text),
                       :domain => 'www.blunt.senate.gov' }
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

    def self.harris(page=1)
      results = []
      url = "https://www.harris.senate.gov/news/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          results << { :source => url,
                       :url => "https://www.harris.senate.gov" + row.css('a').first['href'],
                       :title => row.text.strip,
                       :date => Date.parse(row.previous.previous.text),
                       :domain => 'www.harris.senate.gov' }
      end
      results
    end

    def self.barbaralee(page=1)
      results = []
      url = "https://lee.house.gov/news/press-releases?PageNum_rs=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          title = row.text.strip
          release_url = "https://lee.house.gov" + row.css('a').first['href']
          results << { :source => url,
                       :url => release_url,
                       :title => title,
                       :date => begin row.next.next.text rescue nil end,
                       :domain => 'lee.house.gov'}
      end
      results
    end

    def self.gardner(page=1)
      results = []
      url = "https://www.gardner.senate.gov/newsroom/press-releases?PageNum_rs=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css("#newscontent h2").each do |row|
          title = row.text.strip
          release_url = row.css('a').first['href'].strip
          raw_date = row.previous.previous.text
          date = begin Date.strptime(raw_date, "%m.%d.%y") rescue nil end
          results << { :source => url,
                       :url => release_url,
                       :title => title,
                       :date => date,
                       :domain => 'www.gardner.senate.gov' }
      end
      results
    end

    def self.senate_drupal_new(urls=[], page=0)
      if urls.empty?
        urls = [
          "https://www.smith.senate.gov/press-releases",
          "https://www.romney.senate.gov/press-releases",
          "https://www.mcsally.senate.gov/press-releases",
          "https://www.blackburn.senate.gov/press-releases",
          "https://www.braun.senate.gov/press-releases",
          "https://www.cramer.senate.gov/press-releases",
          "https://www.rosen.senate.gov/press-releases",
          "https://www.sinema.senate.gov/press-releases",
          "https://www.hawley.senate.gov/press-releases"
        ]
      end
      results = []
      urls.each do |url|
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
          "https://www.capito.senate.gov/news/press-releases",
          "https://www.perdue.senate.gov/news/press-releases",
          "https://www.daines.senate.gov/news/press-releases",
          "https://www.leahy.senate.gov/press/releases",
          "https://www.hoeven.senate.gov/news/news-releases",
          "https://www.stabenow.senate.gov/news",
          "https://www.murkowski.senate.gov/press/press-releases",
          "https://www.lankford.senate.gov/news/press-releases",
          "https://www.tomudall.senate.gov/news/press-releases",
          "https://www.republicanleader.senate.gov/newsroom/press-releases",
          "https://www.vanhollen.senate.gov/news/press-releases"
        ]
      end

      results = []

      urls.each do |url|
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
