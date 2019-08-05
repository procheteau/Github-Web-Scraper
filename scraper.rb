require 'rubygems'
require 'httparty'
require 'pry'
require 'nokogiri'

class Scraper
  include HTTParty

  def trending
    url = "https://github.com/trending?since=weekly"
    unparsed_page = HTTParty.get(url)
    parsed_page = Nokogiri::HTML(unparsed_page)
    repo_listings = parsed_page.css('article.Box-row')
    listings = repo_listings.map do |repo_listing|
      contributor_objects = repo_listing.css("img[alt]")
      contributor_array = contributor_objects.map do |object|
        object.attributes["alt"].value.sub(/@/,'')
      end
      listing = {
        name: repo_listing.css('a').text.split[3],
        description: repo_listing.css('p').text.strip,
        language: repo_listing.css("span[@itemprop = 'programmingLanguage']").text,
        contributors: contributor_array
      }
    end
  end

  def languageless(listings_array)
    no_language = []
    listings_array.each do |listing|
      if listing[:language] == ""
        no_language << listing[:name]
      end
    end
    return no_language
  end

  def js_count(listings_array)
    count = 0
    listings_array.each do |listing|
      if listing[:language] == "JavaScript"
        count+=1
      end
    end
    return count
  end

  def print_listings(listings_array)
    output = ""
    listings_array.each do |listing|
      output+="#{listing[:name]}\n"
      output+="===========================\n"
      output+="#{listing[:description]}\n\n"
      output+="Written primarily in #{listing[:language]}\n\n"
      output+="Primary Contributors: "
      listing[:contributors].each do |contributor|
        output+="#{contributor}, "
      end
      output+="\n---------------------------\n\n"
    end
    puts output
  end
end

github = Scraper.new
latest_listings = github.trending
empty = github.languageless(latest_listings)
count = github.js_count(latest_listings)
github.print_listings(latest_listings)
