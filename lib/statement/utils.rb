require 'uri'
require 'cgi'

module Utils
  def self.absolute_link(url, link)
    return link if link =~ /^http/
    ("http://"+URI.parse(url).host + "/"+link).to_s
  end

  def self.remove_generic_urls!(results)
    results = results.reject{|r| r.nil?}
    results.reject{|r| r[:url].nil?}
    results.reject{|r| URI.parse(CGI.escape(r[:url])).path == '/news/' or URI.parse(CGI.escape(r[:url])).path == '/news'}
  end
end
