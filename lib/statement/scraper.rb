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

    def self.member_methods
      [:crenshaw, :capuano, :cold_fusion, :klobuchar, :billnelson, :crapo, :boxer, :burr, :ellison,
      :vitter, :inhofe, :document_query, :swalwell, :fischer, :clark, :edwards, :barton, :schiff,
      :welch, :sessions, :gabbard, :costa, :farr, :mcclintock, :olson, :schumer, :cassidy, :lowey, :mcmorris, :takano,
      :bennie_thompson, :speier, :poe, :grassley, :bennet, :shaheen, :keating, :drupal, :jenkins, :durbin, :rand_paul, :senate_drupal]
    end

    def self.committee_methods
      [:senate_approps_majority, :senate_approps_minority, :senate_banking, :senate_hsag_majority, :senate_hsag_minority, :senate_indian, :senate_aging, :senate_smallbiz_minority, :senate_intel, :house_energy_minority, :house_homeland_security_minority, :house_judiciary_majority, :house_rules_majority, :house_ways_means_majority]
    end

    def self.member_scrapers
      year = current_year
      results = [crenshaw, capuano, cold_fusion(year, nil), klobuchar(year), billnelson(page=0), ellison,
        document_query(page=1), document_query(page=2), swalwell(page=1), crapo, boxer, grassley(page=0), burr, cassidy,
        vitter(year=year), inhofe(year=year), fischer, clark(year=year), edwards, barton, welch,
        sessions(year=year), gabbard, costa, farr, olson, schumer, bennie_thompson, speier, lowey, mcmorris, schiff, takano,
        poe(year=year, month=0), bennet(page=1), shaheen(page=1), perlmutter, keating, drupal, jenkins, durbin(page=1),
        rand_paul(page = 1), senate_drupal].flatten
      results = results.compact
      Utils.remove_generic_urls!(results)
    end

    def self.backfill_from_scrapers
      results = [cold_fusion(2012, 0), cold_fusion(2011, 0), cold_fusion(2010, 0), billnelson(year=2012), document_query(page=3),
        document_query(page=4), grassley(page=1), grassley(page=2), grassley(page=3), burr(page=2), burr(page=3), burr(page=4),
        vitter(year=2012), vitter(year=2011), swalwell(page=2), swalwell(page=3), clark(year=2013),
        sessions(year=2013), pryor(page=1), farr(year=2013), farr(year=2012), farr(year=2011), cassidy(page=2), cassidy(page=3),
        olson(year=2013), schumer(page=2), schumer(page=3), poe(year=2015, month=2), ellison(page=1), ellison(page=2), lowey(page=1),
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

    def self.swalwell(page=1)
      results = []
      url = "http://swalwell.house.gov/category/press-releases/page/#{page}/"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//h3")[0..4].each do |row|
        results << { :source => url, :url => row.children[0]['href'], :title => row.children[0].text, :date => nil, :domain => 'swalwell.house.gov'}
      end
      results
    end

    def self.capuano
      results = []
      base_url = "http://www.house.gov/capuano/news/"
      list_url = base_url + 'date.shtml'
      doc = open_html(list_url)
      return if doc.nil?
      doc.xpath("//a").select{|l| !l['href'].nil? and l['href'].include?('/pr')}[1..-5].each do |link|
        begin
          year = link['href'].split('/').first
          date = Date.parse(link.text.split(' ').first+'/'+year)
        rescue
          date = nil
        end
        results << { :source => list_url, :url => base_url + link['href'], :title => link.text.split(' ',2).last, :date => date, :domain => "www.house.gov/capuano/" }
      end
      return results[0..-5]
    end

    def self.crenshaw(year=current_year, month=nil)
      results = []
      year = current_year if not year
      domain = 'crenshaw.house.gov'
      if month
        url = "http://crenshaw.house.gov/index.cfm/pressreleases?YearDisplay=#{year}&MonthDisplay=#{month}&page=1"
      else
        url = "http://crenshaw.house.gov/index.cfm/pressreleases"
      end
      doc = Statement::Scraper.open_html(url)
      return if doc.nil?
      doc.xpath("//tr")[2..-1].each do |row|
        date_text, title = row.children.map{|c| c.text.strip}.reject{|c| c.empty?}
        next if date_text == 'Date' or date_text.size > 10
        date = Date.parse(date_text)
        results << { :source => url, :url => row.children[3].children.first['href'], :title => title, :date => date, :domain => domain }
      end
      results
    end

    def self.cold_fusion(year=current_year, month=nil, skip_domains=[])
      results = []
      year = current_year if not year
      domains = ['www.ronjohnson.senate.gov','www.risch.senate.gov', 'www.lee.senate.gov', 'www.barrasso.senate.gov', 'www.heitkamp.senate.gov', 'www.shelby.senate.gov', 'www.tillis.senate.gov']
      domains = domains - skip_domains if skip_domains
      domains.each do |domain|
        if domain == 'www.risch.senate.gov'
          if not month
            url = "http://www.risch.senate.gov/public/index.cfm/pressreleases"
          else
            url = "http://www.risch.senate.gov/public/index.cfm/pressreleases?YearDisplay=#{year}&MonthDisplay=#{month}&page=1"
          end
        elsif domain == 'www.tillis.senate.gov'
          if not month
            url = "http://www.tillis.senate.gov/public/index.cfm/press-releases"
          else
            url = "http://www.tillis.senate.gov/public/index.cfm/press-releases?YearDisplay=#{year}&MonthDisplay=#{month}&page=1"
          end
        elsif domain == 'www.shelby.senate.gov'
          if not month
            url = "http://www.shelby.senate.gov/public/index.cfm/newsreleases"
          else
            url = "http://www.shelby.senate.gov/public/index.cfm/newsreleases?YearDisplay=#{year}&MonthDisplay=#{month}&page=1"
          end
        elsif domain == 'www.barrasso.senate.gov'
          if not month
            url = "http://#{domain}/public/index.cfm/news-releases"
          else
            url = "http://#{domain}/public/index.cfm/news-releases?YearDisplay=#{year}&MonthDisplay=#{month}&page=1"
          end
        else
          if not month
            url = "http://#{domain}/public/index.cfm/press-releases"
          else
            url = "http://#{domain}/public/index.cfm/press-releases?YearDisplay=#{year}&MonthDisplay=#{month}&page=1"
          end
        end
        doc = Statement::Scraper.open_html(url)
        return if doc.nil?
        if domain == 'www.lee.senate.gov' or domain == 'www.barrasso.senate.gov' or domain == "www.heitkamp.senate.gov" or domain == 'www.tillis.senate.gov'
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
      url = "http://mcmorris.house.gov/issues/page/#{page}/?tax=types&term=news_releases"
      doc = open_html(url)
      return if doc.nil?
      doc.css(".feed-result").each do |row|
        results << { :source => url, :url => row.children[3].children[3].children.first['href'], :title => row.children[3].children[3].children.first.text.strip, :date => Date.parse(row.children[3].children[1].text), :domain => "mcmorris.house.gov" }
      end
      results
    end

    def self.klobuchar(year=current_year)
      results = []
      url = "http://www.klobuchar.senate.gov/public/news-releases?MonthDisplay=0&YearDisplay=#{year}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//tr")[2..-1].each do |row|
        next if row.text.strip[0..3] == "Date"
        results << { :source => url, :url => row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.strptime(row.children[1].text.strip, "%m/%d/%y"), :domain => "www.klobuchar.senate.gov" }
      end
      results
    end

    def self.poe(year, month=0)
      results = []
      base_url = "http://poe.house.gov"
      month_url = base_url + "/press-releases?MonthDisplay=#{month}&YearDisplay=#{year}"
      doc = open_html(month_url)
      return if doc.nil?
      doc.xpath("//tr")[1..-1].each do |row|
        next if row.children[3].children[0].text.strip == 'Title'
        results << { :source => month_url, :url => base_url + row.children[3].children[0]['href'], :title => row.children[3].children[0].text.strip, :date => Date.strptime(row.children[1].text, "%m/%d/%y"), :domain => "poe.house.gov" }
      end
      results
    end

    def self.lujan
      results = []
      base_url = 'http://lujan.house.gov/'
      doc = open_html(base_url+'index.php?option=com_content&view=article&id=981&Itemid=78')
      return if doc.nil?
      doc.xpath('//ul')[1].children.each do |row|
        next if row.text.strip == ''
        results << { :source => base_url+'index.php?option=com_content&view=article&id=981&Itemid=78', :url => base_url + row.children[0]['href'], :title => row.children[0].text, :date => nil, :domain => "lujan.house.gov" }
      end
      results
    end

    def self.billnelson(page=0)
      results = []
      url = "http://www.billnelson.senate.gov/newsroom/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      dates = doc.xpath("//div[@class='date-box']").map{|d| Date.parse(d.children.map{|x| x.text.strip}.join(" "))}
      (doc/:h3).each_with_index do |row, index|
        results << { :source => url, :url => "http://www.billnelson.senate.gov" + row.children.first['href'], :title => row.children.first.text.strip, :date => dates[index], :domain => "billnelson.senate.gov" }
      end
      results
    end

    def self.rand_paul(page = 1)
      # each page contains a max of 20 results
      page_url = "http://www.paul.senate.gov/news/press?PageNum_rs=#{page}"
      doc = open_html(page_url)
      return if doc.nil?
      results = doc.search('#press .title').inject([]) do |arr, title|
        article_url = URI.join(page_url, title.search('a')[0]['href'])
        article_datestr = title.previous_element.text # e.g. "05.11.15"
        arr << {
          :source => page_url,
          :url => article_url.to_s,
          :domain => article_url.host,
          :title => title.text,
          :date => Date.strptime(article_datestr, '%m.%d.%y')
        }
      end
      results
    end


    def self.patrick_meehan(page = 0)
      # This is a Drupal page and it uses the View plugin, but unlike the other
      # Drupal pages, it does not make use of .views-field-created, and instead, the
      # only Month-Year is given (03 Feb).
      page_url = "https://meehan.house.gov/media-center/press-releases?page=#{page}"
      doc = open_html(page_url)
      return if doc.nil?
      results = doc.search('.view-congress-press-releases .views-row').inject([]) do |arr, article|
        title = article.search('.views-field-title a')[0]
        article_url = URI.join(page_url, title['href'])
        raise "Date still needs to be parsed; thanks a lot Drupal"
        article_datestr = title.previous_element.text
        arr << {
          :source => page_url,
          :url => article_url.to_s,
          :domain => article_url.host,
          :title => title.text,
          :date => Date.strptime(article_datestr, 'SOMETHING')
        }
      end

      results
    end

    def self.schiff(page=1)
      results = []
      url = "http://schiff.house.gov/news/press-releases?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      rows = doc.css("#press").first.css('h2')
      rows.each do |row|
        results << { :source => url, :url => "http://schiff.house.gov" + row.children.first['href'], :title => row.children.last.text.strip, :date => Date.strptime(row.previous.previous.text, "%m.%d.%y"), :domain => "schiff.house.gov" }
      end
      results
    end

    def self.takano(page=1)
      results = []
      url = "http://takano.house.gov/newsroom/press-releases?PageNum_rs=#{page}"
      doc = open_html(url)
      return if doc.nil?
      rows = doc.css("#press").first.css('h2')
      rows.each do |row|
        results << { :source => url, :url => "http://takano.house.gov" + row.children.first['href'], :title => row.children.last.text.strip, :date => Date.strptime(row.previous.previous.text, "%m.%d.%y"), :domain => "takano.house.gov" }
      end
      results
    end

    def self.speier
      results = []
      url = "http://speier.house.gov/index.php?option=com_content&view=category&id=20&Itemid=14"
      doc = open_html(url)
      return if doc.nil?
      rows = doc.css("table.category tr")
      rows.each do |row|
        results << { :source => url, :url => "http://speier.house.gov" + row.children[1].children[1]['href'], :title => row.children[1].children[1].text.strip, :date => Date.parse(row.children[3].text.strip), :domain => "speier.house.gov" }
      end
      results
    end

    def self.burr(page=1)
      results = []
      url = "http://www.burr.senate.gov/press/releases?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      rows = doc.css("#press").first.css('h2')
      rows.each do |row|
        results << { :source => url, :url => "http://www.burr.senate.gov" + row.children.first['href'], :title => row.children.last.text.strip, :date => Date.strptime(row.previous.previous.text, "%m.%d.%y"), :domain => "burr.senate.gov" }
      end
      results
    end

    def self.cassidy(page=1)
      results = []
      url = "http://www.cassidy.senate.gov/newsroom/press-releases?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      rows = doc.css("#press").first.css('h2')
      rows.each do |row|
        results << { :source => url, :url => "http://www.cassidy.senate.gov" + row.children.first['href'], :title => row.children.last.text.strip, :date => Date.strptime(row.previous.previous.text, "%m.%d.%y"), :domain => "cassidy.senate.gov" }
      end
      results
    end

    def self.crapo
      results = []
      base_url = "http://www.crapo.senate.gov/media/newsreleases/"
      url = base_url + "release_all.cfm"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//tr").each do |row|
        results << { :source => url, :url => base_url + row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[1].text.strip.gsub('-','/')), :domain => "crapo.senate.gov" }
      end
      results
    end

    def self.fischer(year=current_year)
      results = []
      url = "http://www.fischer.senate.gov/public/index.cfm/press-releases?MonthDisplay=0&YearDisplay=#{year}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//tr")[2..-1].each do |row|
        next if row.text.strip[0..3] == "Date"
        results << { :source => url, :url => row.children[3].children[0]['href'], :title => row.children[3].text.strip, :date => Date.strptime(row.children[1].text.strip, "%m/%d/%y"), :domain => "fischer.senate.gov" }
      end
      results
    end

    def self.grassley(page=0)
      results = []
      url = "http://www.grassley.senate.gov/news/news-releases?title=&tid=All&date[value]&page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='views-field views-field-field-release-date']").each do |row|
        results << { :source => url, :url => "http://www.grassley.senate.gov" + row.next.next.children[1].children[0]['href'], :title => row.next.next.text.strip, :date => Date.parse(row.text.strip), :domain => "grassley.senate.gov" }
      end
      results
    end

    def self.ellison(page=0)
      results = []
      url = "http://ellison.house.gov/media-center/press-releases?page=#{page}"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='views-field views-field-created datebar']").each do |row|
        results << { :source => url, :url => "http://ellison.house.gov" + row.next.next.children[1].children[0]['href'], :title => row.next.next.text.strip, :date => Date.parse(row.text.strip), :domain => "ellison.house.gov" }
      end
      results
    end

    def self.boxer
      results = []
      url = "http://www.boxer.senate.gov/press/release"
      domain = 'www.boxer.senate.gov'
      doc = open_html(url)
      return if doc.nil?
      doc.css("tr")[1..-1].each do |row|
        next if row.children[1].text == "Sat, January 1st 0000 "
        results << { :source => url, :url => "http://"+domain + row.children[3].children[1]['href'], :title => row.children[3].children[1].text.strip, :date => Date.parse(row.children[1].text), :domain => domain}
      end
      results
    end

    def self.vitter(year=current_year)
      results = []
      url = "http://www.vitter.senate.gov/newsroom/"
      domain = "www.vitter.senate.gov"
      doc = open_html(url+"press?year=#{year}")
      return if doc.nil?
      doc.xpath("//tr")[1..-1].each do |row|
        next if row.text.strip.size < 30
        results << { :source => url, :url => row.children[3].children[0]['href'].strip, :title => row.children[3].text, :date => Date.strptime(row.children[1].text, "%m/%d/%y"), :domain => domain}
      end
      results
    end

    # deprecated
    def self.donnelly(year=current_year)
      results = []
      url = "http://www.donnelly.senate.gov/newsroom/"
      domain = "www.donnelly.senate.gov"
      doc = open_html(url+"press?year=#{year}")
      return if doc.nil?
      doc.xpath("//tr")[1..-1].each do |row|
        next if row.text.strip.size < 30
        results << { :source => url, :url => "http://www.donnelly.senate.gov"+row.children[3].children[1]['href'].strip, :title => row.children[3].text.strip, :date => Date.strptime(row.children[1].text, "%m/%d/%y"), :domain => domain}
      end
      results
    end

    def self.durbin(page=1)
      results = []
      url = "http://www.durbin.senate.gov/newsroom/press-releases?PageNum_rs=#{page}&"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@id='press']//h2").each do |row|
        results << { :source => url, :url => "http://www.durbin.senate.gov"+row.children[0]['href'], :title => row.children[0].text.strip, :date => Date.parse(row.previous.previous.text.gsub(".","/")), :domain => 'www.durbin.senate.gov'}
      end
      results
    end

    def self.inhofe(year=current_year)
      results = []
      url = "http://www.inhofe.senate.gov/newsroom/press-releases?year=#{year}"
      domain = "www.inhofe.senate.gov"
      doc = open_html(url)
      return if doc.nil?
      if doc.xpath("//tr")[1..-1]
        doc.xpath("//tr")[1..-1].each do |row|
          next if row.text.strip.size < 30
          results << { :source => url, :url => row.children[3].children[0]['href'].strip, :title => row.children[3].text, :date => Date.strptime(row.children[1].text, "%m/%d/%y"), :domain => domain}
        end
      end
      results
    end

    def self.clark(year=current_year)
      results = []
      domain = 'katherineclark.house.gov'
      url = "http://katherineclark.house.gov/index.cfm/press-releases?MonthDisplay=0&YearDisplay=#{year}"
      doc = open_html(url)
      return if doc.nil?
      (doc/:tr)[1..-1].each do |row|
        next if row.children[1].text.strip == 'Date'
        results << { :source => url, :date => Date.parse(row.children[1].text.strip), :title => row.children[3].children.text, :url => row.children[3].children[0]['href'], :domain => domain}
      end
      results
    end

    def self.sessions(year=current_year)
      results = []
      domain = 'sessions.senate.gov'
      url = "http://www.sessions.senate.gov/public/index.cfm/news-releases?YearDisplay=#{year}"
      doc = open_html(url)
      return if doc.nil?
      (doc/:tr)[1..-1].each do |row|
        next if row.children[1].text.strip == 'Date'
        results << { :source => url, :date => Date.parse(row.children[1].text), :title => row.children[3].children.text, :url => row.children[3].children[0]['href'], :domain => domain}
      end
      results
    end

    def self.edwards
      results = []
      domain = 'donnaedwards.house.gov'
      url = "http://donnaedwards.house.gov/index.php?option=com_content&view=category&id=10&Itemid=18"
      doc = open_html(url)
      return if doc.nil?
      table = (doc/:table)[4]
      (table/:tr).each do |row|
        results << { :source => url, :url => "http://donnaedwards.house.gov/"+row.children.children[1]['href'], :title => row.children.children[1].text.strip, :date => Date.parse(row.children.children[3].text.strip), :domain => domain}
      end
      results
    end

    def self.barton
      results = []
      domain = 'joebarton.house.gov'
      url = "http://joebarton.house.gov/press-releasescolumns/"
      doc = open_html(url)
      return if doc.nil?
      (doc/:h3)[0..-3].each do |row|
        results << { :source => url, :url => "http://joebarton.house.gov/"+row.children[1]['href'], :title => row.children[1].text.strip, :date => Date.parse(row.next.next.text), :domain => domain}
      end
      results
    end

    def self.welch
      results = []
      domain = 'welch.house.gov'
      url = "http://www.welch.house.gov/press-releases/"
      doc = open_html(url)
      return if doc.nil?
      (doc/:h3).each do |row|
        results << { :source => url, :url => "http://www.welch.house.gov/"+row.children[1]['href'], :title => row.children[1].text.strip, :date => Date.parse(row.next.next.text), :domain => domain}
      end
      results
    end

    def self.gabbard
      results = []
      domain = 'gabbard.house.gov'
      url = "http://gabbard.house.gov/index.php/news/press-releases"
      doc = open_html(url)
      return if doc.nil?
      doc.css('ul.fc_leading li').each do |row|
        results << {:source => url, :url => "http://gabbard.house.gov"+row.children[0].children[1]['href'], :title => row.children[0].children[1].text.strip, :date => Date.parse(row.children[2].text), :domain => domain}
      end
      results
    end

    def self.costa
      results = []
      domain = 'costa.house.gov'
      url = "http://costa.house.gov/index.php/newsroom30/press-releases12"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//div[@class='nspArt']").each do |row|
        results << { :source => url, :url => "http://costa.house.gov" + row.children[0].children[1].children[0]['href'], :title => row.children[0].children[1].children[0].text.strip, :date => Date.parse(row.children[0].children[0].text), :domain => domain}
      end
      results
    end

    def self.farr(year=2015)
      results = []
      domain = 'www.farr.house.gov'
      if year == 2015
        url = "http://www.farr.house.gov/index.php/newsroom/press-releases"
      else
        url = "http://www.farr.house.gov/index.php/newsroom/press-releases-archive/#{year.to_s}-press-releases"
      end
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//tr[@class='cat-list-row0']").each do |row|
        results << { :source => url, :url => "http://farr.house.gov" + row.children[1].children[1]['href'], :title => row.children[1].children[1].text.strip, :date => Date.parse(row.children[3].text.strip), :domain => domain}
      end
      results
    end

    def self.mcclintock
      results = []
      domain = 'mcclintock.house.gov'
      url = "http://mcclintock.house.gov/press-all.shtml"
      doc = open_html(url)
      return if doc.nil?
      doc.css("ul li").first(152).each do |row|
        results << { :source => url, :url => row.children[0].children[1]['href'], :title => row.children[0].children[1].text.strip, :date => Date.parse(row.children[0].children[0].text), :domain => domain}
      end
      results
    end

    def self.olson(year=current_year)
      results = []
      domain = 'olson.house.gov'
      url = "http://olson.house.gov/#{year}-press-releases/"
      doc = open_html(url)
      return if doc.nil?
      (doc/:h3).each do |row|
        results << {:source => url, :url => 'http://olson.house.gov' + row.children[1]['href'], :title => row.children[1].text.strip, :date => Date.parse(row.next.next.text), :domain => domain }
      end
      results
    end

    def self.document_query(page=1)
      results = []
      domains = [
        {"thornberry.house.gov" => 1776},
        {"wenstrup.house.gov" => 2491},
        {"clawson.house.gov" => 2641},
        {"palazzo.house.gov" => 2519},
        {"roe.house.gov" => 1532},
        {"perry.house.gov" => 2607},
        {"rodneydavis.house.gov" => 2427},
        {"kevinbrady.house.gov" => 2657},
        {"loudermilk.house.gov" => 27},
        {"babin.house.gov" => 27},
        {"bridenstine.house.gov" => 2412},
        {"allen.house.gov" => 27},
        {"davidscott.house.gov" => 377},
        {"buddycarter.house.gov" => 27},
        {"grothman.house.gov" => 27},
        {"beyer.house.gov" => 27},
        {"kathleenrice.house.gov" => 27},
        {"hanna.house.gov" => 27},
        {"trentkelly.house.gov" => 27},
        {"lamborn.house.gov" => 27},
        {"wittman.house.gov" => 2670},
        {"kinzinger.house.gov" => 2665},
        {"ellmers.house.gov" => 27},
        {"frankel.house.gov" => 27},
        {"conaway.house.gov" => 1279},
        {'culberson.house.gov' => 2573},
        {'chabot.house.gov' => 2508}
      ]
      domains.each do |domain|
        doc = open_html("http://"+domain.keys.first+"/news/documentquery.aspx?DocumentTypeID=#{domain.values.first}&Page=#{page}")
        return if doc.nil?
        doc.xpath("//div[@class='middlecopy']//li").each do |row|
          results << { :source => "http://"+domain.keys.first+"/news/"+"documentquery.aspx?DocumentTypeID=#{domain.values.first}&Page=#{page}", :url => "http://"+domain.keys.first+"/news/" + row.children[1]['href'], :title => row.children[1].text.strip, :date => Date.parse(row.children[3].text.strip), :domain => domain.keys.first }
        end
      end
      results.flatten
    end

    def self.schumer(page=1)
      results = []
      domain = 'www.schumer.senate.gov'
      url = "http://www.schumer.senate.gov/newsroom/press-releases/table?PageNum_rs=#{page}"
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
      url = "http://www.bennet.senate.gov/?p=releases&pg=#{page}"
      doc = open_html(url)
      return if doc.nil?
      (doc/:h2).each do |row|
        results << {:source => url, :url => 'http://www.bennet.senate.gov' + row.children.first['href'], :title => row.text.strip, :date => Date.parse(row.previous.previous.text), :domain => domain }
      end
      results
    end

    def self.shaheen(page=1)
      results = []
      domain = 'www.shaheen.senate.gov'
      url = "http://www.shaheen.senate.gov/news/press/index.cfm?PageNum_rs=#{page}"
      doc = open_html(url)
      return if doc.nil?
      (doc/:ul)[3].children.each do |row|
        next if row.text.strip == ''
        results << {:source => url, :url => row.children[2].children[0]['href'], :title => row.children[2].text.strip, :date => Date.parse(row.children.first.text), :domain => domain }
      end
      results
    end

    def self.jenkins
      results = []
      domain = 'lynnjenkins.house.gov/'
      url = "http://lynnjenkins.house.gov/index.cfm?sectionid=186"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath("//ul[@class='sectionitems']//li").each do |row|
        results << {:source => url, :url => 'http://lynnjenkins.house.gov' + row.children[3].children[1]['href'], :title => row.children[3].text.strip, :date => Date.parse(row.children[5].text), :domain => domain }
      end
      results
    end

    def self.bennie_thompson
      results = []
      domain = "benniethompson.house.gov"
      url = "http://benniethompson.house.gov/index.php?option=com_content&view=category&id=41&Itemid=148"
      doc = open_html(url)
      return if doc.nil?
      doc.xpath('//*[@id="adminForm"]/table/tbody/tr').each do |row|
        results << {:source => url, :url => 'http://benniethompson.house.gov' + row.children[1].children[1]['href'], :title => row.children[1].children[1].text.strip, :date => Date.parse(row.children[3].text.strip), :domain => domain }
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
        results << {:source => url, :url => 'http://lowey.house.gov' + row.css('h3').first.children.first['href'], :title => row.css('h3').first.children.first.text.strip, :date => Date.parse(row.css(".views-field .field-content")[1].text), :domain => domain }
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
          release_url = "http://#{domain + title_anchor.attr('href')}"
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
      url = "http://boustany.house.gov/#{congress}th-congress/showallitems/"
      doc = open_html(url)
      return if doc.nil?
      (doc/:ul)[13].search(:li).each do |row|
        results << {:source => url, :url => 'http://boustany.house.gov' + row.children.search(:a)[0]['href'], :title => row.children.search(:a)[0].text, :date => Date.parse(row.children[5].text), :domain => domain }
      end
      results
    end

    def self.perlmutter
      results = []
      domain = "perlmutter.house.gov"
      url = "http://#{domain}/index.php/media-center/press-releases-86821"
      doc = open_html(url)
      return if doc.nil?

      doc.css("#adminForm tr")[0..-1].each do |row|
        results << { :source => url, :url => "http://" + domain + row.children[1].children[1]['href'], :title => row.children[1].children[1].text.strip, :date => Date.parse(row.children[3].text), :domain => domain}
      end
      results
    end

    def self.keating
      results = []
      domain = "keating.house.gov"
      source_url = "http://#{domain}/index.php?option=com_content&view=category&id=14&Itemid=13"
      doc = open_html(source_url)
      return if doc.nil?

      doc.css("#adminForm tr")[0..-1].each do |row|
        url = 'http://' + domain + row.children[1].children[1]['href']
        title = row.children[1].children[1].text.strip
        results << { :source => source_url, :url => url, :title => title, :date => Date.parse(row.children[3].text), :domain => domain}
      end
      results
    end

    def self.drupal(urls=[], page=0)
      if urls.empty?
        urls = [
            "http://sherman.house.gov/media-center/press-releases",
            "http://mccaul.house.gov/media-center/press-releases",
            "https://ellison.house.gov/media-center/press-releases",
            "http://mcnerney.house.gov/media-center/press-releases",
            "http://sanford.house.gov/media-center/press-releases",
            "http://butterfield.house.gov/media-center/press-releases",
            "http://walz.house.gov/media-center/press-releases",
            "https://pingree.house.gov/media-center/press-releases",
            "http://wilson.house.gov/media-center/press-releases",
            "https://bilirakis.house.gov/press-releases",
            "http://quigley.house.gov/media-center/press-releases",
            "https://denham.house.gov/media-center/press-releases",
            "https://sewell.house.gov/media-center/press-releases",
            "https://buchanan.house.gov/media-center/press-releases",
            "https://meehan.house.gov/media-center/press-releases",
            "https://olson.house.gov/media-center/press-releases",
            "https://louise.house.gov/media-center/press-releases",
            "https://waters.house.gov/media-center/press-releases",
            "https://walden.house.gov/media-center/press-releases",
            "https://brooks.house.gov/media-center/news-releases",
            "https://swalwell.house.gov/media-center/press-releases",
            "https://lujangrisham.house.gov/media-center/press-releases"
        ]
      end

      results = []

      urls.each do |url|
        source_url = "#{url}?page=#{page}"

        domain =  URI.parse(source_url).host
        doc = open_html(source_url)
        return if doc.nil?

        doc.css("#region-content .views-row").each do |row|
            title_anchor = row.css("h3 a")
            title = title_anchor.text
            release_url = "http://#{domain + title_anchor.attr('href')}"
              raw_date = row.css(".views-field-created").text
            results << { :source => source_url,
                         :url => release_url,
                         :title => title,
                         :date => begin Date.parse(raw_date) rescue nil end,
                         :domain => domain }
        end

        # mike quigley's release page doesn't have dates, so we fetch those individually
        if url == "http://quigley.house.gov/media-center/press-releases"
          results.select{|r| r[:source] == source_url}.each do |result|
            doc = open_html(result[:url])
            result[:date] = Date.parse(doc.css(".pane-content").children[0].text.strip)
          end
        end
      end
      results
    end

    def self.senate_drupal(urls=[], page=0)
      if urls.empty?
        urls = [
          "http://www.durbin.senate.gov/newsroom/press-releases",
          "http://www.capito.senate.gov/news/press-releases",
          "http://www.perdue.senate.gov/news/press-releases",
          "http://www.daines.senate.gov/news/press-releases",
          "http://www.gardner.senate.gov/newsroom/press-releases",
          "http://www.leahy.senate.gov/press/releases",
          "http://www.paul.senate.gov/news/press"
        ]
      end

      results = []

      urls.each do |url|
        source_url = "#{url}?page=#{page}"

        domain =  URI.parse(source_url).host
        doc = open_html(source_url)
        return if doc.nil?

        doc.css("#newscontent h2").each do |row|
            title = row.text.strip
            release_url = "http://#{domain + row.css('a').first['href']}"
              raw_date = row.previous.previous.text
            results << { :source => source_url,
                         :url => release_url,
                         :title => title,
                         :date => begin Date.strptime(raw_date, "%m.%d.%y") rescue nil end,
                         :domain => domain }
        end
      end
      results

    end
  end

end
