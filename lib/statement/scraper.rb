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
      [:klobuchar, :crapo, :burr, :trentkelly, :kilmer, :cardin, :heinrich, :jenkins, :halrogers, :bucshon, :document_query_new, :fulcher, :gardner,
      :wenstrup, :robbishop, :tomrice, :bwcoleman, :manchin, :harris, :timscott, :banks, :senate_drupal_newscontent, :shaheen, :paul, :calvert,
      :inhofe, :document_query, :fischer, :clark, :schiff, :barbaralee, :cantwell, :wyden, :cornyn, :marchant, :connolly, :mast, :hassan, :yarmuth,
      :welch, :schumer, :cassidy, :lowey, :mcmorris, :takano, :lacyclay, :gillibrand, :walorski, :garypeters, :webster, :cortezmasto, :hydesmith,
      :grassley, :bennet, :drupal, :durbin, :senate_drupal, :senate_drupal_new, :rounds, :sullivan, :kennedy, :duckworth, :dougjones, :angusking]
    end

    def self.committee_methods
      [:senate_approps_majority, :senate_approps_minority, :senate_banking, :senate_hsag_majority, :senate_hsag_minority, :senate_indian, :senate_aging, :senate_smallbiz_minority, :senate_intel, :house_energy_minority, :house_homeland_security_minority, :house_judiciary_majority, :house_rules_majority, :house_ways_means_majority]
    end

    def self.member_scrapers
      year = current_year
      results = [klobuchar(year), kilmer, lacyclay, sullivan, halrogers, shaheen, timscott, wenstrup, bucshon, angusking, document_query_new, fulcher, gardner,
        document_query([], page=1), document_query([], page=2), crapo, grassley(page=0), burr, cassidy, cantwell, cornyn, kind, senate_drupal_new, bwcoleman, calvert, dougjones,
        inhofe(year=year), fischer, clark(year=year), welch, trentkelly, barbaralee, cardin, wyden, webster, mast, hassan, cortezmasto, manchin, robbishop, yarmuth,
        schumer, lowey, mcmorris, schiff, takano, heinrich, walorski, jenkins, marchant, garypeters, rounds, connolly, paul, banks, harris, tomrice, hydesmith,
        bennet(page=1), drupal, durbin(page=1), gillibrand, kennedy, duckworth, senate_drupal_newscontent, senate_drupal].flatten
      results = results.compact
      Utils.remove_generic_urls!(results)
    end

    def self.backfill_from_scrapers
      results = [document_query(page=3), cardin(page=2), cornyn(page=1), timscott(page=2), timscott(page=3),
        document_query(page=4), grassley(page=1), grassley(page=2), grassley(page=3), burr(page=2), burr(page=3), burr(page=4), cantwell(page=2),
        clark(year=2013), kilmer(page=2), kilmer(page=3), heinrich(page=2), kind(page=1), walorski(page=2), manchin(page=2), manchin(page=3),
        cassidy(page=2), cassidy(page=3), gillibrand(page=2), issa(page=1), issa(page=2), paul(page=1), paul(page=2), banks(page=2),
        olson(year=2013), schumer(page=2), schumer(page=3), poe(year=2015, month=2), lowey(page=1), wyden(page=2),
        lowey(page=2), lowey(page=3), poe(year=2015, month=1), mcmorris(page=2), mcmorris(page=3), schiff(page=2), schiff(page=3),
        takano(page=2), takano(page=3)].flatten
      Utils.remove_generic_urls!(results)
    end

    def self.committee_scrapers
      year = current_year
      results = [senate_approps_majority, senate_approps_minority, senate_banking(year), senate_hsag_majority(year), senate_hsag_minority(year),
         senate_indian, senate_aging, senate_smallbiz_minority, senate_intel(113, 2013, 2014), house_energy_minority, house_homeland_security_minority,
         house_judiciary_majority, house_rules_majority, house_ways_means_majority].flatten
      Utils.remove_generic_urls!(results)
    end

    ## special cases for committees without RSS feeds

    def self.senate_approps_majority
      results = []
      url = "http://www.appropriations.senate.gov/news.cfm"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='newsDateUnderlined']").each do |date|
        date.next.next.children.reject{|c| c.text.strip.empty?}.each do |row|
          results << { :source => url, :url => url + row.children[0]['href'], :title => row.text, :date => Date.parse(date.text), :domain => "http://www.appropriations.senate.gov/", :party => 'majority' }
        end
      end
      results
    end

    def self.senate_approps_minority
      results = []
      url = "http://www.appropriations.senate.gov/republican.cfm"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='newsDateUnderlined']").each do |date|
        date.next.next.children.reject{|c| c.text.strip.empty?}.each do |row|
          results << { :source => url, :url => url + row.children[0]['href'], :title => row.text, :date => Date.parse(date.text), :domain => "http://www.appropriations.senate.gov/", :party => 'minority' }
        end
      end
      results
    end

    def self.senate_banking(year=current_year)
      results = []
      url = "http://www.banking.senate.gov/public/index.cfm?FuseAction=Newsroom.PressReleases&ContentRecordType_id=b94acc28-404a-4fc6-b143-a9e15bf92da4&Region_id=&Issue_id=&MonthDisplay=0&YearDisplay=#{year}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//tr").each do |row|
        results << { :source => url, :url => "http://www.banking.senate.gov/public/" + row.children[2].children[1]['href'], :title => row.children[2].text.strip, :date => Date.parse(row.children[0].text.strip+", #{year}"), :domain => "http://www.banking.senate.gov/", :party => 'majority' }
      end
      results
    end

    def self.senate_hsag_majority(year=current_year)
      results = []
      url = "http://www.hsgac.senate.gov/media/majority-media?year=#{year}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//tr").each do |row|
        next if row.text.strip.size < 30
        results << { :source => url, :url => row.children[2].children[0]['href'].strip, :title => row.children[2].children[0].text, :date => Date.parse(row.children[0].text), :domain => "http://www.hsgac.senate.gov/", :party => 'majority' }
      end
      results
    end

    def self.senate_hsag_minority(year=current_year)
      results = []
      url = "http://www.hsgac.senate.gov/media/minority-media?year=#{year}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//tr").each do |row|
        next if row.text.strip.size < 30
        results << { :source => url, :url => row.children[2].children[0]['href'].strip, :title => row.children[2].children[0].text, :date => Date.parse(row.children[0].text), :domain => "http://www.hsgac.senate.gov/", :party => 'minority' }
      end
      results
    end

    def self.senate_indian
      results = []
      url = "http://www.indian.senate.gov/news/index.cfm"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//h3").each do |row|
        results << { :source => url, :url => "http://www.indian.senate.gov"+row.children[0]['href'], :title => row.children[0].text, :date => Date.parse(row.previous.previous.text), :domain => "http://www.indian.senate.gov/", :party => 'majority' }
      end
      results
    end

    def self.senate_aging
      results = []
      url = "http://www.aging.senate.gov/pressroom.cfm?maxrows=100&startrow=1&&type=1"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//tr")[6..104].each do |row|
        results << { :source => url, :url => "http://www.aging.senate.gov/"+row.children[2].children[0]['href'], :title => row.children[2].text.strip, :date => Date.parse(row.children[0].text), :domain => "http://www.aging.senate.gov/" }
      end
      results
    end

    def self.senate_smallbiz_minority
      results = []
      url = "http://www.sbc.senate.gov/public/index.cfm?p=RepublicanPressRoom"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//ul[@class='recordList']").each do |row|
        results << { :source => url, :url => row.children[0].children[2].children[0]['href'], :title => row.children[0].children[2].children[0].text, :date => Date.parse(row.children[0].children[0].text), :domain => "http://www.sbc.senate.gov/", :party => 'minority' }
      end
      results
    end

    def self.senate_intel(congress=114, start_year=2015, end_year=2016)
      results = []
      url = "http://www.intelligence.senate.gov/press/releases.cfm?congress=#{congress}&y1=#{start_year}&y2=#{end_year}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//tr[@valign='top']")[7..-1].each do |row|
        results << { :source => url, :url => "http://www.intelligence.senate.gov/press/"+row.children[2].children[0]['href'], :title => row.children[2].children[0].text.strip, :date => Date.parse(row.children[0].text), :domain => "http://www.intelligence.senate.gov/" }
      end
      results
    end

    def self.house_energy_minority
      results = []
      url = "http://democrats.energycommerce.house.gov/index.php?q=news-releases"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='views-field-title']").each do |row|
        results << { :source => url, :url => "http://democrats.energycommerce.house.gov"+row.children[1].children[0]['href'], :title => row.children[1].children[0].text, :date => Date.parse(row.next.next.text.strip), :domain => "http://energycommerce.house.gov/", :party => 'minority' }
      end
      results
    end

    def self.house_homeland_security_minority
      results = []
      url = "http://chsdemocrats.house.gov/press/index.asp?subsection=1"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//li[@class='article']").each do |row|
        results << { :source => url, :url => "http://chsdemocrats.house.gov"+row.children[1]['href'], :title => row.children[1].text.strip, :date => Date.parse(row.children[3].text), :domain => "http://chsdemocrats.house.gov/", :party => 'minority' }
      end
      results
    end

    def self.house_judiciary_majority
      results = []
      url = "http://judiciary.house.gov/news/press2013.html"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//p")[3..60].each do |row|
        next if row.text.size < 30
        results << { :source => url, :url => row.children[5]['href'], :title => row.children[0].text, :date => Date.parse(row.children[1].text.strip), :domain => "http://judiciary.house.gov/", :party => 'majority' }
      end
      results
    end

    def self.house_rules_majority
      results = []
      url = "http://www.rules.house.gov/News/Default.aspx"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//tr")[1..-2].each do |row|
        next if row.text.strip.size < 30
        results << { :source => url, :url => "http://www.rules.house.gov/News/"+row.children[0].children[1].children[0]['href'], :title => row.children[0].children[1].children[0].text, :date => Date.parse(row.children[2].children[1].text.strip), :domain => "http://www.rules.house.gov/", :party => 'majority' }
      end
      results
    end

    def self.house_ways_means_majority
      results = []
      url = "http://waysandmeans.house.gov/news/documentquery.aspx?DocumentTypeID=1496"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//ul[@class='UnorderedNewsList']").children.each do |row|
        next if row.text.strip.size < 10
        results << { :source => url, :url => "http://waysandmeans.house.gov"+row.children[1].children[1]['href'], :title => row.children[1].children[1].text, :date => Date.parse(row.children[3].children[0].text.strip), :domain => "http://waysandmeans.house.gov/", :party => 'majority' }
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
        if domain == 'www.lee.senate.gov' or domain == 'www.barrasso.senate.gov' or domain == "www.heitkamp.senate.gov" or domain == 'www.tillis.senate.gov' or domain == 'www.moran.senate.gov' or domain == 'www.feinstein.senate.gov' or domain == 'www.shelby.senate.gov'
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
      doc.xpath("//tr")[2..-1].each do |row|
        next if row.text.strip[0..3] == "Date"
        results << { :source => url, :url => "https://www.klobuchar.senate.gov" + row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.strptime(row.children[1].text.strip, "%m/%d/%y"), :domain => "www.klobuchar.senate.gov" }
      end
      results
    end

    def self.lujan
      results = []
      base_url = 'https://lujan.house.gov/'
      doc = open_html(base_url+'index.php?option=com_content&view=article&id=981&Itemid=78')
      return if doc.nil?
      doc.xpath('//ul')[1].children.each do |row|
        next if row.text.strip == ''
        results << { :source => base_url+'index.php?option=com_content&view=article&id=981&Itemid=78', :url => base_url + row.children[0]['href'], :title => row.children[0].text, :date => nil, :domain => "lujan.house.gov" }
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
      if doc.xpath("//tr")[1..-1]
        doc.xpath("//tr")[1..-1].each do |row|
          next if row.text.strip.size < 30
          results << { :source => url, :url => row.children[3].children[0]['href'].strip, :title => row.children[3].text.strip, :date => Date.strptime(row.children[1].text, "%m/%d/%y"), :domain => domain}
        end
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
      url = "https://walorski.house.gov/news/"
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
          {"babin.house.gov" => 27},
          {"allen.house.gov" => 27},
          {"holding.house.gov" => 27},
          {"davidscott.house.gov" => 377},
          {"buddycarter.house.gov" => 27},
          {"grothman.house.gov" => 27},
          {"beyer.house.gov" => 27},
          {"kathleenrice.house.gov" => 27},
          {"lamborn.house.gov" => 27},
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
          {'norman.house.gov' => 27},
          {'matsui.house.gov' => 27},
          {'carbajal.house.gov' => 27},
          {'budd.house.gov' => 27},
          {'delbene.house.gov' => 27},
          {'gosar.house.gov' => 27},
          {'wassermanschultz.house.gov' => 27},
          {'weber.house.gov' => 27},
          {'plaskett.house.gov' => 27},
          {'gomez.house.gov' => 27},
          {'gwenmoore.house.gov' => 27},
          {'reed.house.gov' => 27},
          {'susandavis.house.gov' => 1782},
          {'meadows.house.gov' => 27},
          {'jasonsmith.house.gov' => "1951:27"},
          {'mckinley.house.gov' => 27},
          {'hill.house.gov' => 27}
        ]
      end
      domains.each do |domain|
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
          {'markgreen.house.gov' => 27},
          {'chuygarcia.house.gov' => 27},
          {'fletcher.house.gov' => 27},
          {'crenshaw.house.gov' => 27}
        ]
      end
      domains.each do |domain|
        source_url = "https://"+domain.keys.first+"/news/documentquery.aspx?DocumentTypeID=#{domain.values.first}&Page=#{page}"
        doc = Statement::Scraper.open_html(source_url)
        return if doc.nil?
        doc.xpath("//article").each do |row|
          results << { :source => source_url, :url => "https://"+domain.keys.first+"/news/" + row.css("h3 a").first['href'], :title => row.css("h3").text.strip, :date => Date.parse(row.css('time').last.text), :domain => domain.keys.first }
        end
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

    def self.calvert(page=0)
      results = []
      domain = "calvert.house.gov"
      url = "https://calvert.house.gov/media/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.css(".view-content .views-row").first(10).each do |row|
        results << {:source => url, :url => 'https://calvert.house.gov' + row.css('h3').first.children.first['href'], :title => row.css('h3').first.children.first.text.strip, :date => Date.parse(row.css(".views-field .field-content")[1].text), :domain => domain }
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
            "https://pingree.house.gov/media-center/press-releases",
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
            "https://dankildee.house.gov/media/press-releases",
            "https://walberg.house.gov/media/press-releases",
            "https://smucker.house.gov/media/press-releases",
            "https://speier.house.gov/media-center/press-releases",
            "https://peteking.house.gov/media-center/statements",
            "https://gianforte.house.gov/media-center/press-releases",
            "https://price.house.gov/newsroom/press-releases",
            "https://lofgren.house.gov/media/press-releases",
            "https://lesko.house.gov/media",
            "https://watkins.house.gov/media/press-releases",
            "https://vandrew.house.gov/media/press-releases",
            "https://allred.house.gov/media/press-releases",
            "https://armstrong.house.gov/media/press-releases",
            "https://axne.house.gov/media/press-releases",
            "https://baird.house.gov/media/press-releases",
            "https://brindisi.house.gov/media/press-releases",
            "https://burchett.house.gov/media/press-releases",
            "https://casten.house.gov/media/press-releases",
            "https://cline.house.gov/media/press-releases",
            "https://craig.house.gov/media/press-releases",
            "https://crow.house.gov/media/press-releases",
            "https://cunningham.house.gov/media/press-releases",
            "https://cisneros.house.gov/media/press-releases",
            "https://cox.house.gov/media/press-releases",
            "https://davids.house.gov/media/press-releases",
            "https://delgado.house.gov/media/press-releases",
            "https://dean.house.gov/media/press-releases",
            "https://escobar.house.gov/media/press-releases",
            "https://finkenauer.house.gov/media/press-releases",
            "https://sylviagarcia.house.gov/media/press-releases",
            "https://anthonygonzalez.house.gov/media/press-releases",
            "https://gooden.house.gov/media/press-releases",
            "https://guest.house.gov/media/press-releases",
            "https://golden.house.gov/media/press-releases",
            "https://haaland.house.gov/media/press-releases",
            "https://hayes.house.gov/media/press-releases",
            "https://horn.house.gov/media/press-releases",
            "https://katiehill.house.gov/media/press-releases",
            "https://hagedorn.house.gov/media/press-releases",
            "https://harder.house.gov/media/press-releases",
            "https://dustyjohnson.house.gov/media/press-releases",
            "https://johnjoyce.house.gov/media/press-releases",
            "https://kim.house.gov/media/press-releases",
            "https://susielee.house.gov/media/press-releases",
            "https://luria.house.gov/media/press-releases",
            "https://andylevin.house.gov/media/press-releases",
            "https://mikelevin.house.gov/media/press-releases",
            "https://malinowski.house.gov/media/press-releases",
            "https://meuser.house.gov/media/press-releases",
            "https://miller.house.gov/media/press-releases",
            "https://morelle.house.gov/media/press-releases",
            "https://mucarsel-powell.house.gov/media/press-releases",
            "https://mcbath.house.gov/media/press-releases",
            "https://mcadams.house.gov/media/press-releases",
            "https://neguse.house.gov/media/press-releases",
            "https://ocasio-cortez.house.gov/media/press-releases",
            "https://omar.house.gov/media/press-releases",
            "https://pappas.house.gov/media/press-releases",
            "https://pence.house.gov/media/press-releases",
            "https://phillips.house.gov/media/press-releases",
            "https://pressley.house.gov/media/press-releases",
            "https://porter.house.gov/media/press-releases",
            "https://reschenthaler.house.gov/media/press-releases",
            "https://riggleman.house.gov/media/press-releases",
            "https://johnrose.house.gov/media/press-releases",
            "https://roy.house.gov/media/press-releases",
            "https://rouda.house.gov/media/press-releases",
            "https://sannicolas.house.gov/media/press-releases",
            "https://scanlon.house.gov/media/press-releases",
            "https://sherrill.house.gov/media/press-releases",
            "https://slotkin.house.gov/media/press-releases",
            "https://spano.house.gov/media/press-releases",
            "https://stanton.house.gov/media/press-releases",
            "https://stauber.house.gov/media/press-releases",
            "https://steil.house.gov/media/press-releases",
            "https://steube.house.gov/media/press-releases",
            "https://stevens.house.gov/media/press-releases",
            "https://schrier.house.gov/media/press-releases",
            "https://timmons.house.gov/media/press-releases",
            "https://tlaib.house.gov/media/press-releases",
            "https://trone.house.gov/media/press-releases",
            "https://torressmall.house.gov/media/press-releases",
            "https://underwood.house.gov/media/press-releases",
            "https://vandrew.house.gov/media/press-releases",
            "https://waltz.house.gov/media/press-releases",
            "https://watkins.house.gov/media/press-releases",
            "https://wexton.house.gov/media/press-releases",
            "https://wild.house.gov/media/press-releases",
            "https://wright.house.gov/media/press-releases"
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
          "https://www.young.senate.gov/newsroom/press-releases"
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

    def self.hydesmith(page=0)
      results = []
      url = "https://www.hydesmith.senate.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".views-row").each do |row|
          results << { :source => url,
                       :url => "https://www.hydesmith.senate.gov" + row.css('a').first['href'],
                       :title => row.css('h2').text.strip,
                       :date => Date.parse(row.children[1].children[2].text),
                       :domain => 'www.hydesmith.senate.gov' }
      end
      results
    end

    def self.dougjones(page=0)
      results = []
      url = "https://www.jones.senate.gov/press-releases?page=#{page}"
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.css(".views-row").each do |row|
          results << { :source => url,
                       :url => "https://www.jones.senate.gov" + row.css('a').first['href'],
                       :title => row.css('h2').text.strip,
                       :date => Date.parse(row.children[1].children[2].text),
                       :domain => 'www.jones.senate.gov' }
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

    def self.barbaralee
      results = []
      url = "https://lee.house.gov/news/press-releases"
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
          "https://www.sinema.senate.gov/press-releases"
        ]
      end
      results = []
      urls.each do |url|
        uri = URI(url)
        source_url = "#{url}?page=#{page}"

        domain =  URI.parse(source_url).host
        doc = Statement::Scraper.open_html(source_url)
        if url == "https://www.smith.senate.gov/press-releases"
          doc.css('.views-row').each do |row|
            results << {:source => url, :url => "https://#{domain}" + row.css('h2 a').first['href'], :title => row.css('h2').text.strip, :date => Date.parse(row.css(".field-name-post-date").text), :domain => domain}
          end
        else
          doc.css('.views-row').each do |row|
            if row.css('h2 a').size == 1
              results << {:source => url, :url => "https://#{domain}" + row.css('h2 a').first['href'], :title => row.css('h2').text.strip, :date => Date.parse(row.css("time").text), :domain => domain}
            end
          end
        end
      end
      results
    end

    def self.senate_drupal(urls=[], page=0)
      if urls.empty?
        urls = [
          "https://www.durbin.senate.gov/newsroom/press-releases",
          "https://www.capito.senate.gov/news/press-releases",
          "https://www.perdue.senate.gov/news/press-releases",
          "https://www.daines.senate.gov/news/press-releases",
          "https://www.leahy.senate.gov/press/releases",
          "https://www.hoeven.senate.gov/news/news-releases",
          "https://www.murkowski.senate.gov/press/press-releases",
          "https://www.stabenow.senate.gov/news",
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
