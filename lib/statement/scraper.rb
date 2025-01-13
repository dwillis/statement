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
      [:crapo, :trentkelly, :heinrich, :document_query_new, :barr, :media_body, :steube, :bera, :meeks, :sykes, :barragan, :castor, :marshall, :hawley, :jetlisting_h2, :barrasso,
      :timscott, :senate_drupal_newscontent, :shaheen, :paul, :tlaib, :grijalva, :aguilar, :bergman, :scanlon, :gimenez, :mcgovern, :foxx, :clarke, :jayapal, :carey, :mikelee,
      :fischer, :clark, :sykes, :cantwell, :wyden, :cornyn, :connolly, :mast, :hassan, :rickscott, :joyce, :gosar, :article_block_h2, :griffith, :daines, :vanhollen, :lummis,
      :schumer, :cassidy, :takano, :gillibrand, :garypeters, :cortezmasto, :hydesmith, :recordlist, :rosen, :schweikert, :article_block_h2_date, :hagerty, :graham, :article_span_published,
      :grassley, :lofgren, :senate_drupal, :tinasmith, :rounds, :kennedy, :duckworth, :angusking, :tillis, :emmer, :house_title_header, :lujan, :ronjohnson, :mullin, :brownley,
      :porter, :jasonsmith, :bacon, :capito, :tonko, :larsen, :mooney, :ellzey, :media_digest, :crawford, :lucas, :article_newsblocker, :pressley, :reschenthaler, :norcross,
      :jeffries, :article_block, :jackreed, :blackburn, :article_block_h1, :schatz, :kaine, :cruz, :padilla, :baldwin, :clyburn, :titus, :houlahan, :react, :tokuda, :huizenga,
      :moran, :murray, :thune, :tuberville, :warner, :boozman, :fetterman, :rubio, :whitehouse, :wicker, :toddyoung, :britt, :markey, :budd, :elementor_post_date, :markkelly,
      :ossoff, :vance, :welch, :cotton]
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
      results = [shaheen, timscott, angusking, document_query_new, media_body, scanlon, bera, meeks, norcross, vanhollen, barrasso, mikelee, brownley, cotton,
        crapo, grassley(page=1), baldwin, cruz, schatz, cassidy, cantwell, cornyn, tinasmith, tlaib, daines, marshall, hawley, jetlisting_h2, hagerty, graham, murray,
        fischer, kaine, padilla, clark, trentkelly, wyden, mast, hassan, cortezmasto, react, tokuda, steube, foxx, clarke, griffith, carey, ronjohnson, moran, tuberville,
        schumer, takano, heinrich, garypeters, rounds, connolly, paul, hydesmith, rickscott, mooney, ellzey, bergman, gimenez, article_block_h2, barragan, castor, 
        lofgren, gillibrand, kennedy, duckworth, senate_drupal_newscontent, senate_drupal, tillis, barr, crawford, lujan, jayapal, lummis, thune, mullin, welch,
        jasonsmith, bacon, capito, house_title_header, recordlist, tonko, aguilar, rosen, media_digest, pressley, reschenthaler, article_block_h2_date, huizenga,
        larsen, grijalva, jeffries, article_block, jackreed, blackburn, article_block_h1, clyburn, titus, joyce, houlahan, lucas, schweikert, gosar, mcgovern, warner,
        boozman, rubio, whitehouse, wicker, toddyoung, britt, markey, budd, elementor_post_date, fetterman, article_span_published, markkelly, ossoff, vance].flatten
      results = results.compact
      Utils.remove_generic_urls!(results)
    end

    def self.backfill_from_scrapers
      results = [cornyn(page=1), timscott(page=2), timscott(page=3), grassley(page=2), grassley(page=3), grassley(page=4), cantwell(page=2),
        clark(year=2013), heinrich(page=2), cassidy(page=2), cassidy(page=3), gillibrand(page=2), paul(page=1), paul(page=2), schumer(page=2), schumer(page=3), wyden(page=2),
        sykes(page=2), sykes(page=3), takano(page=2), takano(page=3)].flatten
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

    def self.bowman(page=1)
      results = []
      url = "https://bowman.house.gov/media/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".link-list-press-item").each do |row|
        results << { :source => url, :url => "https://bowman.house.gov" + row.css('a').first['href'].strip, :title => row.css('a').first.text.strip, :date => Date.parse(row.css('td')[0].text), :domain => "bowman.house.gov" }
      end
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

    ## special cases for members without RSS feeds

    def self.house_title_header(urls=[], page=1)
      if urls.empty?
        urls = [
          "https://fulcher.house.gov/press-releases",
          "https://mcbath.house.gov/press-releases",
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
          "https://biggs.house.gov/media/press-releases",
          "https://johnjoyce.house.gov/media/press-releases",
          "https://larson.house.gov/media-center/press-releases",
          "https://kaptur.house.gov/media-center/press-releases",
          "https://benniethompson.house.gov/media/press-releases",
          "https://walberg.house.gov/media/press-releases",
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
          "https://shontelbrown.house.gov/media/press-releases",
          "https://stansbury.house.gov/media/press-releases",
          "https://troycarter.house.gov/media/press-releases",
          "https://letlow.house.gov/media/press-releases",
          "https://matsui.house.gov/media",
          "https://harris.house.gov/media/press-releases",
          "https://wagner.house.gov/media-center/press-releases",
          "https://pappas.house.gov/media/press-releases",
          "https://crow.house.gov/media/press-releases",
          "https://chuygarcia.house.gov/media/press-releases",
          "https://omar.house.gov/media/press-releases",
          "https://underwood.house.gov/media/press-releases",
          "https://casten.house.gov/media/press-releases",
          "https://fleischmann.house.gov/media/press-releases",
          "https://stevens.house.gov/media/press-releases",
          "https://guest.house.gov/media/press-releases",
          "https://morelle.house.gov/media/press-releases",
          "https://beatty.house.gov/media-center/press-releases",
          "https://robinkelly.house.gov/media-center/press-releases",
          "https://moolenaar.house.gov/media-center/press-releases",
          "https://adams.house.gov/media-center/press-releases",
          "https://mfume.house.gov/media/press-releases",
          "https://tiffany.house.gov/media/press-releases",
          "https://barrymoore.house.gov/media/press-releases",
          "https://obernolte.house.gov/media/press-releases",
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
          "https://garbarino.house.gov/media/press-releases",
          "https://malliotakis.house.gov/media/press-releases",
          "https://bice.house.gov/media/press-releases",
          "https://bentz.house.gov/media/press-releases",
          "https://mace.house.gov/media/press-releases",
          "https://harshbarger.house.gov/media/press-releases",
          "https://blakemoore.house.gov/media/press-releases",
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
          "https://magaziner.house.gov/media/press-releases",
          "https://vanorden.house.gov/media/press-releases",
          "https://hunt.house.gov/media/press-releases",
          "https://casar.house.gov/media/press-releases",
          "https://crockett.house.gov/media/press-releases",
          "https://luttrell.house.gov/media/press-releases",
          "https://deluzio.house.gov/media/press-releases",
          "https://lalota.house.gov/media/press-releases",
          "https://vasquez.house.gov/media/press-releases",
          "https://scholten.house.gov/media/press-releases",
          "https://ivey.house.gov/media/press-releases",
          "https://sorensen.house.gov/media/press-releases",
          "https://nunn.house.gov/media/press-releases",
          "https://laurellee.house.gov/media/press-releases",
          "https://mills.house.gov/media/press-releases",
          "https://ciscomani.house.gov/media/press-releases",
          "https://democraticleader.house.gov/media/press-releases",
          "https://horsford.house.gov/media/press-releases",
          "https://cleaver.house.gov/media-center/press-releases",
          "https://aderholt.house.gov/media-center/press-releases",
          "https://courtney.house.gov/media-center/press-releases",
          "https://stauber.house.gov/media/press-releases",
          "https://mccaul.house.gov/media-center/press-releases",
          "https://foster.house.gov/media/press-releases",
          "https://schakowsky.house.gov/media/press-releases",
          "https://craig.house.gov/media/press-releases",
          "https://desaulnier.house.gov/media-center/press-releases",
          "https://scalise.house.gov/media/press-releases",
          "https://neguse.house.gov/media/press-releases",
          "https://murphy.house.gov/media/press-releases",
          "https://boyle.house.gov/media-center/press-releases",
          "https://calvert.house.gov/media/press-releases",
          "https://bobbyscott.house.gov/media-center/press-releases",
          "https://bilirakis.house.gov/media/press-releases",
          "https://delauro.house.gov/media-center/press-releases",
          "https://norton.house.gov/media/press-releases",
          "https://mikethompson.house.gov/newsroom/press-releases",
          "https://smucker.house.gov/media/press-releases",
          "https://degette.house.gov/media-center/press-releases",
          "https://ruiz.house.gov/media-center/press-releases",
          "https://sherman.house.gov/media-center/press-releases",
          "https://quigley.house.gov/media-center/press-releases",
          "https://waters.house.gov/media-center/press-releases",
          "https://swalwell.house.gov/media-center/press-releases",
          "https://khanna.house.gov/media/press-releases",
          "https://panetta.house.gov/media/press-releases",
          "https://schneider.house.gov/media/press-releases",
          "https://dankildee.house.gov/media/press-releases",
          "https://sylviagarcia.house.gov/media/press-releases",
          "https://susielee.house.gov/media/press-releases",
          "https://amo.house.gov/press-releases",
          "https://mcclellan.house.gov/media/press-releases",
          "https://rulli.house.gov/media/press-releases",
          "https://suozzi.house.gov/media/press-releases",
          "https://fong.house.gov/media/press-releases",
          "https://lopez.house.gov/media/press-releases",
          "https://mciver.house.gov/media/press-releases",
          "https://wied.house.gov/media/press-releases",
          "https://ericaleecarter.house.gov/media/press-releases",
          "https://moulton.house.gov/news/press-releases",
          "https://nehls.house.gov/media",
          "https://meng.house.gov/media-center/press-releases",
          "https://lindasanchez.house.gov/media-center/press-releases",
          "https://lamalfa.house.gov/media-center/press-releases",
          "https://dondavis.house.gov/media/press-releases",
          "https://strong.house.gov/media/press-releases",
          "https://chu.house.gov/media-center/press-releases",
          "https://lieu.house.gov/media-center/press-releases",
          "https://joewilson.house.gov/media/press-releases",
          "https://zinke.house.gov/media/press-releases",
          "https://pelosi.house.gov/news/press-releases",
          "https://rutherford.house.gov/media/press-releases",
          "https://veasey.house.gov/media-center/press-releases",
          "https://garamendi.house.gov/media/press-releases",
          "https://kustoff.house.gov/media/press-releases",
          "https://gonzalez.house.gov/media/press-releases",
          "https://costa.house.gov/media/press-releases",
          "https://houchin.house.gov/media/press-releases",
          "https://williams.house.gov/media-center/press-releases",
          "https://menendez.house.gov/media/press-releases",
          "https://pocan.house.gov/media-center/press-releases",
          "https://ogles.house.gov/media/press-releases",
          "https://velazquez.house.gov/media-center/press-releases",
          "https://bonamici.house.gov/media/press-releases",
          "https://keithself.house.gov/media/press-releases",
          "https://bishop.house.gov/media-center/press-releases",
          "https://hoyer.house.gov/media",
          "https://burlison.house.gov/media/press-releases",
          "https://jonathanjackson.house.gov/media/press-releases",
          "https://davids.house.gov/media/press-releases",
          "https://mccollum.house.gov/media/press-releases",
          "https://adamsmith.house.gov/news/press-releases",
          "https://hankjohnson.house.gov/media-center/press-releases",
          "https://evans.house.gov/media/press-releases",
          "https://salinas.house.gov/media/press-releases",
          "https://pallone.house.gov/media/press-releases",
          "https://ramirez.house.gov/media/press-releases",
          "https://graves.house.gov/media/press-releases",
          "https://cole.house.gov/media-center/press-releases",
          "https://jordan.house.gov/media/press-releases",
          "https://hageman.house.gov/media/press-releases"
        ]
      end
      results = []
      urls.each do |url|
        sleep(0.5)
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

    def self.youngkim
      results = []
      url = "https://youngkim.house.gov/media/press-releases/"
      doc = open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        next if row.children[1].text == 'Date'
        results << { :source => url, :url => row.at_css("h2 a")['href'], :title => row.at_css("h2 a").text, :date => Date.parse(row.at_css("p").text), :domain => "youngkim.house.gov" }
      end
      results
    end

    def self.carey(page=1)
      results = []
      url = "https://carey.house.gov/media/press-releases/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        next if row.children[1].text == 'Date'
        results << { :source => url, :url => row.at_css("h2 a")['href'], :title => row.at_css("h2 a").text, :date => Date.parse(row.at_css("p").text), :domain => "carey.house.gov" }
      end
      results
    end

    def self.jayapal(page=1)
      results = []
      url = "https://jayapal.house.gov/category/news/page/#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        next if row.children[1].text == 'Date'
        results << { :source => url, :url => row.at_css("h2 a")['href'], :title => row.at_css("h2 a").text.strip, :date => Date.parse(row.at_css("time")['pubdate']), :domain => "jayapal.house.gov" }
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
          "landsman.house.gov",
          "moskowitz.house.gov",
          "gottheimer.house.gov",
          "kiggans.house.gov",
          "luna.house.gov",
          "maxmiller.house.gov",
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

    def self.wicker(page=1)
      results = []
      url = "https://www.wicker.senate.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".element").each do |row|
        results << { :source => url, :url => row.css('a').first['href'], :title => row.css(".post-media-list-title").text, :date => Date.parse(row.css(".post-media-list-date").text), :domain => "www.wicker.senate.gov" }
      end
      results
    end

    def self.moran(page=1)
      results = []
      url = "https://www.moran.senate.gov/public/index.cfm/news-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("table tbody tr").each do |row|
        results << { :source => url, :url => "https://www.moran.senate.gov" + row.at_css('a')['href'], :title => row.at_css('a').text, :date => Date.parse(row.at_css('td.recordListDate').text), :domain => "www.moran.senate.gov" }
      end
      results
    end

    def self.boozman(page=1)
      results = []
      url = "https://www.boozman.senate.gov/public/index.cfm/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("table tbody tr").each do |row|
        results << { :source => url, :url => "https://www.boozman.senate.gov" + row.at_css('a')['href'], :title => row.at_css('a').text, :date => Date.parse(row.at_css('td.recordListDate').text), :domain => "www.boozman.senate.gov" }
      end
      results
    end

    def self.thune(page=1)
      results = []
      url = "https://www.thune.senate.gov/public/index.cfm/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("table tbody tr").each do |row|
        results << { :source => url, :url => "https://www.thune.senate.gov" + row.at_css('a')['href'], :title => row.at_css('a').text, :date => Date.parse(row.at_css('td.recordListDate').text), :domain => "www.thune.senate.gov" }
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
          "https://www.murphy.senate.gov/newsroom/press-releases",
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
         results << { :source => url, :url => row.css('h1 a').first['href'], :title => row.css('h1 a').text.strip, :date => Date.parse(row.css('.ArticleBlock__date').text), :domain => domain }
       end
      end
      results
    end

    def self.article_block_h2(urls=[], page=1)
      if urls.empty?
        urls = [
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
          "https://www.collins.senate.gov/newsroom/press-releases",
          "https://www.hirono.senate.gov/news/press-releases",
          "https://www.ernst.senate.gov/news/press-releases"
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

    def self.markey(page=1)
      results = []
      domain = 'www.markey.senate.gov'
      url = "https://www.markey.senate.gov/news/press-releases?pagenum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".ArticleBlock").each do |row|
        results << { :source => url, :url => row.css('a').first['href'], :title => row.css("a").first.text.strip, :date => Date.parse(row.css('.ArticleBlock__date').text), :domain => domain }
      end
      results
    end

    def self.cotton(page=1)
      results = []
      domain = 'www.cotton.senate.gov'
      url = "https://www.cotton.senate.gov/news/press-releases?pagenum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".ArticleBlock").each do |row|
        results << { :source => url, :url => row.css('a').first['href'], :title => row.css("a").first.text.strip, :date => Date.parse(row.css('.ArticleBlock__date').text), :domain => domain }
      end
      results
    end

    def self.sykes(page=1)
      results = []
      url = "https://sykes.house.gov/media/press-releases?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css("table#browser_table tbody tr")
      rows.each do |row|
        next if row.at_css("a").nil?
        results << { :source => url, :url => "https://sykes.house.gov" + row.css('a').first['href'].strip, :title => row.css('a').first.text.strip, :date => Date.parse(row.css("time").text), :domain => "sykes.house.gov" }
      end
      results
    end

    def self.tokuda(page=1)
      results = []
      url = "https://tokuda.house.gov/media/press-releases?PageNum_rs=#{page}&"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css("#press").first.css('h2')
      rows.each do |row|
        results << { :source => url, :url => "https://tokuda.house.gov" + row.css('a')[0]['href'], :title => row.children[1].text.strip, :date => Date.parse(row.previous.previous.text), :domain => "tokuda.house.gov" }
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

    def self.britt(page=1)
      results = []
      url = "https://www.britt.senate.gov/media/press-releases/?jsf=jet-engine:press-list&pagenum=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css(".jet-listing-grid__item")
      rows.each do |row|
        results << { :source => url, :url => row.css("a").first['href'], :title => row.at_css("h3 a").text.strip, :date => Date.strptime(row.at_css("h3.elementor-heading-title").text.strip, "%m.%d.%Y"), :domain => "www.britt.senate.gov" }
      end
      results
    end

    def self.toddyoung(page=1)
      results = []
      url = "https://www.young.senate.gov/newsroom/press-releases/?jsf=jet-engine:press-list&pagenum=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css(".jet-listing-grid__item")
      rows.each do |row|
        results << { :source => url, :url => row.css("a").first['href'], :title => row.css("a").text.strip, :date => Date.parse(row.css("span.elementor-post-info__item--type-date").text.strip), :domain => "www.young.senate.gov" }
      end
      results
    end

    def self.markkelly(page=1)
      results = []
      url = "https://www.kelly.senate.gov/newsroom/press-releases/?jsf=jet-engine:press-list&pagenum=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('div.jet-listing-grid__item').each do |row|
        results << { :source => url, :url => row.css("h3 a").first['href'], :title => row.css("h3 a").text.strip, :date => Date.parse(row.css("span.elementor-post-info__item--type-date").text.strip), :domain => "www.kelly.senate.gov" }
      end
      results
    end

    def self.hagerty(page=1)
      results = []
      url = "https://www.hagerty.senate.gov/press-releases/?et_blog&sf_paged=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css("article.et_pb_post")
      rows.each do |row|
        results << { :source => url, :url => row.at_css("h2 a")['href'], :title => row.at_css("h2 a").text.strip, :date => Date.parse(row.at_css("p span.published").text), :domain => "www.hagerty.senate.gov" }
      end
      results
    end

    def self.budd(page=1)
      results = []
      url = "https://www.budd.senate.gov/category/news/press-releases/page/#{page}/?et_blog"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css("article.et_pb_post")
      rows.each do |row|
        results << { :source => url, :url => row.at_css("h2 a")['href'], :title => row.at_css("h2 a").text.strip, :date => Date.parse(row.at_css("p span.published").text), :domain => "www.budd.senate.gov" }
      end
      results
    end

    def self.vance(page=1)
      results = []
      url = "https://www.vance.senate.gov/press-releases/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".elementor .post").each do |row|
        results << { :source => url, :url => row.at_css("h2 a")['href'], :title => row.at_css("h2 a").text.strip, :date => Date.parse(row.at_css("span.elementor-post-info__item--type-date").text), :domain => "www.vance.senate.gov" }
      end
      results
    end

    def self.lummis(page=1)
      results = []
      url = "https://www.lummis.senate.gov/press-releases/page/#{page}/?et_blog"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css("article.et_pb_post")
      rows.each do |row|
        results << { :source => url, :url => row.at_css("h2 a")['href'], :title => row.at_css("h2 a").text.strip, :date => Date.parse(row.at_css("p span.published").text), :domain => "www.lummis.senate.gov" }
      end
      results
    end

    def self.welch(page=1)
      results = []
      url = "https://www.welch.senate.gov/category/press-release/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css("article")
      rows.each do |row|
        results << { :source => url, :url => row.at_css("a")['href'], :title => row.at_css("h2").text.strip, :date => Date.parse(row.at_css(".postDate span").text), :domain => "www.welch.senate.gov" }
      end
      results
    end

    def self.rubio(page=1)
      results = []
      url = "https://www.rubio.senate.gov/news/page/#{page}/?et_blog"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css("article.et_pb_post")
      rows.each do |row|
        results << { :source => url, :url => row.at_css("h3 a")['href'], :title => row.at_css("h3 a").text.strip, :date => Date.parse(row.at_css("p span.published").text), :domain => "www.rubio.senate.gov" }
      end
      results
    end

    def self.jetlisting_h2(urls=[], page=1)
      results = []
      if urls.empty?
        urls = [
          "https://www.lankford.senate.gov/newsroom/press-releases/?jsf=jet-engine:press-list&pagenum=",
          "https://www.ricketts.senate.gov/newsroom/press-releases/?jsf=jet-engine:press-list&pagenum="
        ]
      end
      urls.each do |url|
        doc = Statement::Scraper.open_html("#{url}#{page}")
        return if doc.nil?
        rows = doc.css(".jet-listing-grid__item")
        rows.each do |row|
          results << { :source => url, :url => row.css("h2 a").first['href'], :title => row.css("h2 a").text.strip, :date => Date.parse(row.css("span.elementor-post-info__item--type-date").text.strip), :domain => URI.parse(url).host }
        end
      end
      results
    end

    def self.cornyn(page=1, posts_per_page=15)
      results = []
      url = "https://www.cornyn.senate.gov/wp-admin/admin-ajax.php?action=jet_smart_filters&provider=jet-engine%2Fdefault&defaults[post_status]=publish&defaults[found_posts]=1261&defaults[max_num_pages]=85&defaults[post_type]=news&defaults[orderby]=&defaults[order]=DESC&defaults[paged]=0&defaults[posts_per_page]=#{posts_per_page}&settings[lisitng_id]=16387&settings[columns]=1&settings[columns_tablet]=&settings[columns_mobile]=&settings[column_min_width]=240&settings[column_min_width_tablet]=&settings[column_min_width_mobile]=&settings[inline_columns_css]=false&settings[post_status][]=publish&settings[use_random_posts_num]=&settings[posts_num]=20&settings[max_posts_num]=9&settings[not_found_message]=No+data+was+found&settings[is_masonry]=&settings[equal_columns_height]=&settings[use_load_more]=&settings[load_more_id]=&settings[load_more_type]=click&settings[load_more_offset][unit]=px&settings[load_more_offset][size]=0&settings[loader_text]=&settings[loader_spinner]=&settings[use_custom_post_types]=yes&settings[custom_post_types][]=news&settings[hide_widget_if]=&settings[carousel_enabled]=&settings[slides_to_scroll]=1&settings[arrows]=true&settings[arrow_icon]=fa+fa-angle-left&settings[dots]=&settings[autoplay]=true&settings[pause_on_hover]=true&settings[autoplay_speed]=5000&settings[infinite]=true&settings[center_mode]=&settings[effect]=slide&settings[speed]=500&settings[inject_alternative_items]=&settings[scroll_slider_enabled]=&settings[scroll_slider_on][]=desktop&settings[scroll_slider_on][]=tablet&settings[scroll_slider_on][]=mobile&settings[custom_query]=&settings[custom_query_id]=&settings[_element_id]=&props[found_posts]=1261&props[max_num_pages]=85&props[page]=0&paged=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      json = JSON.load(doc.text)
      content = Nokogiri::HTML(json['content'])
      content.css(".elementor-widget-wrap").each do |row|
        results << { :source => "https://www.cornyn.senate.gov/news/", 
        :url => row.at_css("h2 a")['href'], 
        :title => row.at_css("h2 a").text, 
        :date => Date.parse(row.at_css("span.elementor-heading-title").text), 
        :domain => "www.cornyn.senate.gov" }
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

    def self.vanhollen(page=1)
      results = []
      url = "https://www.vanhollen.senate.gov/news/press-releases?pagenum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("ul li.PageList__item").each do |row|
        results << { :source => url, :url => row.css('a').first['href'], :title => row.css('a').first.text.strip, :date => Date.parse(row.css('p').text.gsub('.','/')), :domain => "www.vanhollen.senate.gov" }
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

    def self.garypeters(page=1)
      results = []
      url = "https://www.peters.senate.gov/newsroom/press-releases?PageNum_rs=#{page}&"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.ArticleBlock").each do |row|
        results << { :source => url, :url => row.at_css('a')['href'], :title => row.at_css('h2').text, :date => Date.parse(row.at_css('p').text.gsub('.','/')), :domain => 'www.peters.senate.gov'}
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

    def self.rounds(page=1)
      results = []
      url = "https://www.rounds.senate.gov/newsroom/press-releases?pagenum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.ArticleBlock").each do |row|
        results << { :source => url, :url => row.at('a')['href'], :title => row.at('a').text.strip, :date => Date.parse(row.css("p").text.gsub(".","/")), :domain => 'www.rounds.senate.gov'}
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

    def self.gillibrand(page=1)
      results = []
      url = "https://www.gillibrand.senate.gov/press-releases/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".et_pb_ajax_pagination_container article").each do |row|
        results << { :source => url, 
        :url => row.at_css('a')['href'],
        :title => row.at_css('h2 a').text, 
        :date => Date.parse(row.at_css('p .published').text.strip), 
        :domain => "www.gillibrand.senate.gov" }
      end
      results
    end

    def self.heinrich(page=1)
      results = []
      url = "https://www.heinrich.senate.gov/newsroom/press-releases?PageNum_rs=#{page}&"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.ArticleBlock").each do |row|
        results << { :source => url, :url => row.at_css('a')['href'], :title => row.at_css('h2').text, :date => Date.parse(row.at_css('p').text), :domain => 'www.heinrich.senate.gov'}
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

    def self.meeks(page=0)
      results = []
      domain = 'meeks.house.gov'
      url = "https://meeks.house.gov/media/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".views-row").first(10).each do |row|
        results << { :source => url, :url => "https://meeks.house.gov"+row.at_css("a.h4")['href'], :title => row.at_css("a.h4").text, :date => Date.parse(row.at_css(".evo-card-date").text), :domain => domain}
      end
      results
    end

    def self.clyburn
      results = []
      domain = 'clyburn.house.gov'
      url = "https://clyburn.house.gov/press-releases/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('.elementor-post__card').each do |row|
        results << { :source => url, :url => row.css("a").attr('href').value, :title => row.css("h3 a").text.strip, :date => Date.parse(row.css("span.elementor-post-date").text.strip), :domain => domain}
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

    def self.jeffries(page=1)
      results = []
      domain = 'jeffries.house.gov'
      url = "https://jeffries.house.gov/category/press-release/page/#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").first(10).each do |row|
        results << { :source => url, :url => row.at_css('a')['href'], :title => row.css("h1").text.strip, :date => Date.parse(row.at_css('time').text.strip), :domain => domain }
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
          {"mikerogers.house.gov" => 27},
          {'nadler.house.gov' => 1753},
          {'debbiedingell.house.gov' => 27},
          {'gomez.house.gov' => 27},
          {"beyer.house.gov" => 27},
          {"waltz.house.gov" => 27},
          {'escobar.house.gov' => 27},
          {'arrington.house.gov' => 27},
          {'valadao.house.gov' => 27},
          {'weber.house.gov' => 27},
          {"grothman.house.gov" => 27},
          {"norman.house.gov" => 27},
          {"buddycarter.house.gov" => 27},
          {"trahan.house.gov" => 27},
          {"gwenmoore.house.gov" => 27},
          {'carbajal.house.gov' => 27},
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
          {'rouzer.house.gov' => 27},
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
        results << {:source => url, :url => "https://titus.house.gov/news/" + row.css("h2 a").first['href'], :title => row.css("h2").text.strip, :date => Date.parse(row.css('time').first['datetime']), :domain => 'titus.house.gov' }
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

    def self.schumer(page=1)
      results = []
      domain = 'www.schumer.senate.gov'
      url = "https://www.schumer.senate.gov/newsroom/press-releases?pagenum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("div.ArticleBlock").each do |row|
        results << { :source => url,
                     :url => row.css('a').first['href'],
                     :title => row.at_css('h3').text,
                     :date => Date.parse(row.at_css('p').text),
                     :domain => domain }
      end
      results
    end

    def self.article_span_published(urls=[], page=1)
      if urls.empty?
        urls = [
          "https://www.bennet.senate.gov/news/page/",
          "https://www.hickenlooper.senate.gov/press/page/"
        ]
      end

      results = []
      urls.each do |url|
        puts url
        doc = Statement::Scraper.open_html("#{url}#{page}")
        return if doc.nil?
        doc.css("article").each do |row|
          results << { :source => url,
                       :url => row.at_css("h3 a")['href'],
                       :title => row.at_css("h3 a").text,
                       :date => Date.parse(row.at_css("span.published").text),
                       :domain => URI.parse(url).host }
        end
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
          "harder.house.gov",
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
          "https://sessions.house.gov/press-releases",
          "https://vanduyne.house.gov/press-releases",
          "https://finstad.house.gov/press-releases",
          "https://mcclain.house.gov/press-releases",
          "https://scottpeters.house.gov/press-releases",
          "https://franklin.house.gov/press-releases",
          "https://ross.house.gov/press-releases",
          "https://gonzales.house.gov/press-releases",
          "https://buchanan.house.gov/press-releases",
          "https://markgreen.house.gov/press-releases",
          "https://halrogers.house.gov/press-releases",
          "https://www.klobuchar.senate.gov/public/index.cfm/news-releases",
          "https://www.risch.senate.gov/public/index.cfm/pressreleases",
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

    def self.barrasso(page=1)
      results = []
      url = "https://www.barrasso.senate.gov/public/index.cfm/news-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("table tbody tr").each do |row|
        results << { :source => url, :url => row.at_css('a')['href'], :title => row.at_css('a').text, :date => Date.parse(row.at_css('td.recordListDate').text), :domain => "www.barrasso.senate.gov" }
      end
      results
    end

    def self.graham(page=1)
      results = []
      url = "https://www.lgraham.senate.gov/public/index.cfm/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("table tbody tr").each do |row|
        results << { :source => url, :url => row.at_css('a')['href'], :title => row.at_css('a').text, :date => Date.parse(row.at_css('td.recordListDate').text), :domain => "www.lgraham.senate.gov" }
      end
      results
    end

    def self.norcross(page=1)
      results = []
      url = "https://norcross.house.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".media-digest-body").each do |row|
        page_url = "https://norcross.house.gov"+ row.at_css("a.media-digest-body-link")['href']
        page = Statement::Scraper.open_html(page_url)
        begin
          date = Date.parse(page.at_css("h4 span.date").text)
        rescue
          next
        end
        results << { :source => url, :url => page_url, :title => row.at_css(".post-media-digest-title").text.strip, :date => date, :domain => "norcross.house.gov" }
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

    def self.steube(page=1)
      results = []
      domain = "steube.house.gov"
      url = "https://steube.house.gov/category/press-releases/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article.item").each do |row|
        results << {:source => url, :url => row.css('a').first['href'], :title => row.css('h3').text, :date => Date.parse(row.css("span.date").first.text), :domain => domain }
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

    def self.clarke(page=1)
      results = []
      domain = "clarke.house.gov"
      url = "https://clarke.house.gov/category/pr/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".post").each do |row|
        next if row.at_css('a').nil?
        results << {:source => url, :url => row.css('a').first['href'], :title => row.css('h2').text, :date => Date.parse(row.css("p").text), :domain => domain }
      end
      results
    end

    def self.barragan(page=1)
      results = []
      domain = "barragan.house.gov"
      url = "https://barragan.house.gov/category/news-releases/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".post").each do |row|
        next if row.at_css('a').nil?
        results << {:source => url, :url => "https://barragan.house.gov"+ row.css('a').first['href'], :title => row.css('h2').text, :date => Date.parse(row.css("p").text), :domain => domain }
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
        page_url = "https://houlahan.house.gov"+ row.at_css('a')['href'].strip
        page = Statement::Scraper.open_html(page_url)
        date = Date.parse(page.css(".topnewstext").text)
        results << {:source => url, :url => page_url, :title => row.at_css('a').text, :date => date, :domain => domain }
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

    def self.bera(page=1)
      results = []
      domain = 'bera.house.gov'
      url = "https://bera.house.gov/news/documentquery.aspx?DocumentTypeID=2402&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << {:source => url, :url => "https://bera.house.gov/"+ row.at_css('a')['href'], :title => row.at_css('a').text, :date => row.at_css("time")['datetime'], :domain => domain }
      end
      results
    end

    def self.article_newsblocker(domains=[], page=1)
      results = []
      if domains.empty?
        domains = [
          "balderson.house.gov",
          "case.house.gov",
          "donalds.house.gov",
          "clyde.house.gov",
          "pfluger.house.gov",
          "jackson.house.gov",
          "ezell.house.gov",
          "pettersen.house.gov",
          "brecheen.house.gov",
          "carter.house.gov",
          "baird.house.gov",
          "greene.house.gov",
          "frankel.house.gov",
          "loudermilk.house.gov",
          "wilson.house.gov",
          "lawler.house.gov",
          "balint.house.gov",
          "maloy.house.gov",
          "kennedy.house.gov",
          "alford.house.gov",
          "cline.house.gov",
          "fry.house.gov",
          "moran.house.gov",
          "fallon.house.gov",
          "fernandez.house.gov",
          "james.house.gov",
          "delbene.house.gov",
          "vandrew.house.gov",
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

    def self.foxx(page=1)
      results = []
      domain = 'foxx.house.gov'
      url = "https://foxx.house.gov/news/documentquery.aspx?DocumentTypeID=2367&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << {:source => url, :url => "https://foxx.house.gov/news/"+ row.at_css('a')['href'], :title => row.at_css('a').text.strip, :date => Date.parse(row.css("time").text), :domain => domain }
      end
      results
    end

    def self.griffith(page=1)
      results = []
      domain = 'morgangriffith.house.gov'
      url = "https://morgangriffith.house.gov/news/documentquery.aspx?DocumentTypeID=2235&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << {:source => url, :url => "https://morgangriffith.house.gov/news/"+ row.at_css('a')['href'], :title => row.at_css('a').text.strip, :date => Date.parse(row.css("time").text), :domain => domain }
      end
      results
    end

    def self.huizenga(page=1)
      results = []
      domain = 'huizenga.house.gov'
      url = "https://huizenga.house.gov/news/documentquery.aspx?DocumentTypeID=2041&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << {:source => url, :url => "https://huizenga.house.gov/news/"+ row.at_css('a')['href'], :title => row.at_css('a').text.strip, :date => Date.parse(row.css("time").text), :domain => domain }
      end
      results
    end

    def self.castor(page=1)
      results = []
      domain = 'castor.house.gov'
      url = "https://castor.house.gov/news/documentquery.aspx?DocumentTypeID=821&Page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << {:source => url, :url => "https://castor.house.gov/news/"+ row.at_css('a')['href'], :title => row.at_css('a').text.strip, :date => Date.parse(row.css("time").text), :domain => domain }
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

    def self.brownley(page=1)
      results = []
      domain = 'juliabrownley.house.gov'
      url = "https://juliabrownley.house.gov/category/press-releases/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article.news-item").each do |row|
        results << {:source => url, :url => row.at_css('a')['href'], :title => row.at_css('h2').text.strip, :date => Date.parse(row.at_css("time")['pubdate']), :domain => domain }
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

    def self.lofgren(page=0)
      results = []
      url = "https://lofgren.house.gov/media/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('.card-body').each do |row|
        results << { :source => url,
                     :url => "https://lofgren.house.gov" + row.css('.h3 a').first['href'],
                     :title => row.css('.h3').text,
                     :date => Date.parse(row.css('.row').text),
                     :domain => 'lofgren.house.gov' }
      end
      results
    end

    def self.senate_drupal_newscontent(urls=[], page=1)
      results = []
      if urls.empty?
        urls = [
          "https://huffman.house.gov/media-center/press-releases",
          "https://castro.house.gov/media-center/press-releases",
          "https://mikelevin.house.gov/media/press-releases",
          "https://watsoncoleman.house.gov/newsroom/press-releases",
          "https://auchincloss.house.gov/media/press-releases",
          "https://vargas.house.gov/media-center/press-releases",
          "https://correa.house.gov/press",
          "https://thanedar.house.gov/media/press-releases",
          "https://casten.house.gov/media/press-releases",
          "https://sarajacobs.house.gov/news/press-releases",
          "https://blakemoore.house.gov/media/press-releases",
          "https://mcgarvey.house.gov/media/press-releases",
          "https://torres.house.gov/media-center/press-releases",
          "https://www.durbin.senate.gov/newsroom/press-releases",
          "https://www.warren.senate.gov/newsroom/press-releases"
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

    def self.elementor_post_date(urls=[], page=1)
      if urls.empty?
        urls = [
          "https://www.sanders.senate.gov/media/press-releases/page/",
          "https://www.merkley.senate.gov/news/press-releases/"
        ]
      end

      results = []
      urls.each do |url|
        uri = URI(url)
        source_url = "#{url}#{page}/"
        domain =  URI.parse(source_url).host
        doc = Statement::Scraper.open_html(source_url)
        return if doc.nil?
        doc.css('.elementor-post__text').each do |row|
          results << { :source => url,
                       :url => row.css('a').first['href'],
                       :title => row.css('h2').text.strip,
                       :date => Date.parse(row.at_css('.elementor-post-date').text.strip),
                       :domain => domain }
        end
      end
      results
    end

    def self.fetterman(page=1)
      results = []
      url = "https://www.fetterman.senate.gov/press-release/page/#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('article').each do |row|
        results << { :source => url,
                      :url => row.at_css('h3 a')['href'],
                      :title => row.at_css('h3 a').text.strip,
                      :date => Date.parse(row.css('span.elementor-post-date').text.strip),
                      :domain => 'www.fetterman.senate.gov' }
      end
      results
    end

    def self.marshall(page=1, posts_per_page=20)
      results = []
      url = "https://www.marshall.senate.gov/wp-admin/admin-ajax.php?action=jet_smart_filters&provider=jet-engine%2Fpress-list&defaults%5Bpost_status%5D%5B%5D=publish&defaults%5Bpost_type%5D%5B%5D=press_releases&defaults%5Bposts_per_page%5D=6&defaults%5Bpaged%5D=1&defaults%5Bignore_sticky_posts%5D=1&settings%5Blisitng_id%5D=67853&settings%5Bcolumns%5D=1&settings%5Bcolumns_tablet%5D=&settings%5Bcolumns_mobile%5D=&settings%5Bpost_status%5D%5B%5D=publish&settings%5Buse_random_posts_num%5D=&settings%5Bposts_num%5D=6&settings%5Bmax_posts_num%5D=9&settings%5Bnot_found_message%5D=No+data+was+found&settings%5Bis_masonry%5D=&settings%5Bequal_columns_height%5D=&settings%5Buse_load_more%5D=&settings%5Bload_more_id%5D=&settings%5Bload_more_type%5D=click&settings%5Bload_more_offset%5D%5Bunit%5D=px&settings%5Bload_more_offset%5D%5Bsize%5D=0&settings%5Bloader_text%5D=&settings%5Bloader_spinner%5D=&settings%5Buse_custom_post_types%5D=yes&settings%5Bcustom_post_types%5D%5B%5D=press_releases&settings%5Bhide_widget_if%5D=&settings%5Bcarousel_enabled%5D=&settings%5Bslides_to_scroll%5D=1&settings%5Barrows%5D=true&settings%5Barrow_icon%5D=fa+fa-angle-left&settings%5Bdots%5D=&settings%5Bautoplay%5D=true&settings%5Bautoplay_speed%5D=5000&settings%5Binfinite%5D=true&settings%5Bcenter_mode%5D=&settings%5Beffect%5D=slide&settings%5Bspeed%5D=500&settings%5Binject_alternative_items%5D=&settings%5Bscroll_slider_enabled%5D=&settings%5Bscroll_slider_on%5D%5B%5D=desktop&settings%5Bscroll_slider_on%5D%5B%5D=tablet&settings%5Bscroll_slider_on%5D%5B%5D=mobile&settings%5Bcustom_query%5D=&settings%5Bcustom_query_id%5D=&settings%5B_element_id%5D=press-list&settings%5Bjet_cct_query%5D=&settings%5Bjet_rest_query%5D=&props%5Bfound_posts%5D=1484&props%5Bmax_num_pages%5D=248&props%5Bpage%5D=1&paged=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      json = JSON.load(doc.text)
      content = Nokogiri::HTML(json['content'])
      content.css(".elementor-widget-wrap").each do |row|
        results << { :source => "https://www.marshall.senate.gov/newsroom/press-releases", 
        :url => row.at_css("h4 a")['href'], 
        :title => row.at_css("h4 a").text, 
        :date => Date.parse(row.at_css("span.elementor-post-info__item--type-date").text.strip), 
        :domain => "www.marshall.senate.gov" }
      end
      results
    end

    def self.tuberville(page=1)
      results = []
      url = "https://www.tuberville.senate.gov/wp-admin/admin-ajax.php?action=jet_smart_filters&provider=jet-engine%2Fpress-list&defaults%5Bpost_status%5D%5B%5D=publish&defaults%5Bpost_type%5D=press_releases&defaults%5Bposts_per_page%5D=10&defaults%5Bpaged%5D=1&defaults%5Bignore_sticky_posts%5D=1&settings%5Blisitng_id%5D=64835&settings%5Bcolumns%5D=1&settings%5Bcolumns_tablet%5D=&settings%5Bcolumns_mobile%5D=&settings%5Bpost_status%5D%5B%5D=publish&settings%5Buse_random_posts_num%5D=&settings%5Bposts_num%5D=10&settings%5Bmax_posts_num%5D=9&settings%5Bnot_found_message%5D=No+data+was+found&settings%5Bis_masonry%5D=&settings%5Bequal_columns_height%5D=&settings%5Buse_load_more%5D=&settings%5Bload_more_id%5D=&settings%5Bload_more_type%5D=click&settings%5Bload_more_offset%5D%5Bunit%5D=px&settings%5Bload_more_offset%5D%5Bsize%5D=0&settings%5Bloader_text%5D=&settings%5Bloader_spinner%5D=&settings%5Buse_custom_post_types%5D=&settings%5Bcustom_post_types%5D=&settings%5Bhide_widget_if%5D=&settings%5Bcarousel_enabled%5D=&settings%5Bslides_to_scroll%5D=1&settings%5Barrows%5D=true&settings%5Barrow_icon%5D=fa+fa-angle-left&settings%5Bdots%5D=&settings%5Bautoplay%5D=true&settings%5Bautoplay_speed%5D=5000&settings%5Binfinite%5D=true&settings%5Bcenter_mode%5D=&settings%5Beffect%5D=slide&settings%5Bspeed%5D=500&settings%5Binject_alternative_items%5D=&settings%5Bscroll_slider_enabled%5D=&settings%5Bscroll_slider_on%5D%5B%5D=desktop&settings%5Bscroll_slider_on%5D%5B%5D=tablet&settings%5Bscroll_slider_on%5D%5B%5D=mobile&settings%5Bcustom_query%5D=&settings%5Bcustom_query_id%5D=&settings%5B_element_id%5D=press-list&props%5Bfound_posts%5D=918&props%5Bmax_num_pages%5D=92&props%5Bpage%5D=1&paged=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      json = JSON.load(doc.text)
      content = Nokogiri::HTML(json['content'])
      content.css(".elementor-widget-wrap").each do |row|
        results << { :source => "https://www.tuberville.senate.gov/newsroom/press-releases", 
        :url => row.at_css("h4 a")['href'], 
        :title => row.at_css("h4 a").text, 
        :date => Date.parse(row.at_css("span.elementor-post-info__item--type-date").text.strip), 
        :domain => "www.tuberville.senate.gov" }
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
      url = "https://www.cortezmasto.senate.gov/news/press-releases/?jsf=jet-engine:press-list&pagenum=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('.jet-listing-grid .ArticleBlock').each do |row|
        results << { :source => url,
                      :url => row.at_css("h2 a")['href'],
                      :title => row.at_css("h2 a").text.strip,
                      :date => Date.parse(row.at_css("li span.elementor-icon-list-text").text.strip),
                      :domain => "www.cortezmasto.senate.gov" }
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

    def self.whitehouse(page=1)
      results = []
      url = "https://www.whitehouse.senate.gov/news/release/?jsf=jet-engine:press-list&pagenum=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('div.jet-listing-grid__item').each do |row|
        next if row.at_css('h3 a').nil?
        results << { :source => url,
                     :url => row.at_css('h3 a')['href'],
                     :title => row.css('h3 a').text.strip,
                     :date => Date.parse(row.css('h3').first.text.strip),
                     :domain => 'www.whitehouse.senate.gov' }
      end
      results
    end

    def self.mullin(page=1)
      results = []
      url = "https://www.mullin.senate.gov/newsroom/press-releases/?jsf=jet-engine:press-list&pagenum=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('div.jet-listing-grid__item').each do |row|
        next if row.at_css('h5 a').nil?
        results << { :source => url,
                     :url => row.at_css('h5 a')['href'],
                     :title => row.css('h5 a').text.strip,
                     :date => Date.parse(row.css('span.elementor-post-info__item--type-date').text.strip.gsub('.','/')),
                     :domain => 'www.mullin.senate.gov' }
      end
      results
    end

    def self.warnock(page=1)
      results = []
      url = "https://www.warnock.senate.gov/newsroom/press-releases/?jsf=jet-engine:press-list&pagenum=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('div.jet-listing-grid__item').each do |row|
        next if row.at_css('h4 a').nil?
        results << { :source => url,
                     :url => row.at_css('h4 a')['href'],
                     :title => row.css('h4 a').text.strip,
                     :date => Date.parse(row.css('span.elementor-post-info__item--type-date').text.strip.gsub('.','/')),
                     :domain => 'www.warnock.senate.gov' }
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
                     :date => Date.parse(row.css('li').first(3).map{|x| x.text.strip}.join(' ')),
                     :domain => 'www.lujan.senate.gov' }
      end
      results
    end

    def self.timscott(page=1)
      results = []
      domain = "www.scott.senate.gov"
      url = "https://www.scott.senate.gov/media-center/press-releases/jsf/jet-engine:press-list/pagenum/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('.jet-listing-grid .elementor-widget-wrap').each do |row|
        results << { :source => url,
                      :url => row.at_css("h3 a")['href'],
                      :title => row.at_css("h3 a").text,
                      :date => Date.parse(row.at_css("li span.elementor-icon-list-text").text.strip),
                      :domain => domain }
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

    def self.paul(page=1)
      results = []
      domain = "www.paul.senate.gov"
      url = "https://www.paul.senate.gov/news/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
          results << { :source => url,
                       :url => row.at_css("h2 a")['href'],
                       :title => row.at_css("h2 a").text,
                       :date => Date.parse(row.at_css("span.published").text),
                       :domain => domain }
      end
      results
    end

    def self.warner(page=1)
      results = []
      url = "https://www.warner.senate.gov/public/index.cfm/pressreleases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('article').each do |row|
        results << { :source => url, :url => "https://www.warner.senate.gov" + row.at_css('h1 a')['href'], :title => row.at_css('h1 a').text.strip, :date => Date.parse(row.at_css('h4').text.strip), :domain => "www.warner.senate.gov" }
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

    def self.mikelee(page=1)
      results = []
      url = "https://www.lee.senate.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css(".element")
      rows.each do |row|
        results << { :source => url, :url => row.css('a').first['href'], :title => row.css('.element-title').text.strip, :date => Date.parse(row.css('.element-date').text), :domain => "www.lee.senate.gov" }
      end
      results
    end

    def self.ronjohnson(page=1)
      results = []
      url = "https://www.ronjohnson.senate.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      rows = doc.css(".element")[1..-2]
      rows.each do |row|
        results << { :source => url, :url => row.css('a').first['href'], :title => row.css('.element-title').text.strip, :date => Date.parse(row.css('span.element-datetime').text), :domain => "www.ronjohnson.senate.gov" }
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

    def self.daines(page=1)
      results = []
      domain = "www.daines.senate.gov"
      url = "https://www.daines.senate.gov/news/press-releases/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('.elementor-post__text').each do |row|
        results << { :source => url,
                      :url => row.css('a').first['href'],
                      :title => row.css('h3').text.strip,
                      :date => Date.parse(row.css('.elementor-post-date').text.strip),
                      :domain => domain }
        end
      results
    end

    def self.ossoff(page=1)
      results = []
      domain = "www.ossoff.senate.gov"
      url = "https://www.ossoff.senate.gov/press-releases/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css("article").each do |row|
        results << { :source => url,
                      :url => row.css('a').first['href'],
                      :title => row.css('h3').text.strip,
                      :date => Date.parse(row.css('.elementor-post-date').text.strip),
                      :domain => domain }
        end
      results
    end

    def self.murray(page=1)
      results = []
      domain = "www.murray.senate.gov"
      url = "https://www.murray.senate.gov/category/press-releases/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('.elementor-post__text').each do |row|
        results << { :source => url,
                      :url => row.css('a').first['href'],
                      :title => row.css('h2').text.strip,
                      :date => Date.parse(row.css('.elementor-post-date').text.strip),
                      :domain => domain }
        end
      results
    end

    def self.shaheen(page=1)
      results = []
      domain = "www.shaheen.senate.gov"
      url = "https://www.shaheen.senate.gov/news/press?PageNum_rs=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".ArticleBlock").each do |row|
        results << { :source => url, :url => row.at_css('a')['href'], :title => row.at_css(".ArticleTitle").text, :date => Date.parse(row.at_css("time").text.gsub(".","/")), :domain => domain }
      end
      results
    end

    def self.hawley(page=1)
      results = []
      url = "https://www.hawley.senate.gov/press-releases/page/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('article .post').each do |row|
        results << { :source => url,
                      :url => row.at_css('h2 a')['href'],
                      :title => row.css('h2 a').text.strip,
                      :date => Date.parse(row.css('span.published').text.strip),
                      :domain => 'www.hawley.senate.gov' }
      end
      results
    end

    def self.tinasmith(page=1)
      results = []
      url = "https://www.smith.senate.gov/press-releases/#{page}/"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css('.elementor-post__text').each do |row|
        results << { :source => url,
                      :url => row.css('a').first['href'],
                      :title => row.css('h3').text.strip,
                      :date => Date.parse(row.css('.elementor-post-date').text.strip),
                      :domain => 'www.smith.senate.gov' }
      end
      results
    end

    def self.senate_drupal(urls=[], page=1)
      if urls.empty?
        urls = [
          "https://www.hoeven.senate.gov/news/news-releases",
          "https://www.murkowski.senate.gov/press/press-releases",
          "https://www.republicanleader.senate.gov/newsroom/press-releases",
          "https://www.sullivan.senate.gov/newsroom/press-releases"
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
