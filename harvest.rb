#!/usr/bin/env ruby

require 'open-uri'
require 'rubygems'
require 'hpricot'

puts "Harvest stock information from the London Stock Exchange"

LONDON_HOST = 'http://www.londonstockexchange.com'
LONDON_PATH = '/exchange/prices-and-news/stocks/prices-search/stock-prices-search.html?'

def fetch_page(query)
  puts "Fetching #{query}..."
  open(LONDON_HOST + LONDON_PATH + query) { |f| Hpricot(f) }
end

def get_next_query(doc)
  link = doc.at('//div[@class="paging"]//a[@title="Next"]')
  if link
    link['href'].sub(LONDON_PATH,'')
  end
end

def get_data(doc)
  output = []
  (doc/"table.table_dati tbody tr").each do |row|
    stock = ''
    (row/"td").slice(0,3).each do |cell|
      stock << cell.inner_text.strip + "\t"
    end
    output.push stock.chop
  end
  output.join("\n")
end


print "initial to fetch? (return for all) : "
initial = STDIN.gets.strip.upcase[0,1]
initials = /[A-Z0]/.match(initial) ? initial.to_a : ('A'..'Z').to_a.insert(0,0)

dest = ARGV.size ? ARGV[0] : nil
puts "ok, will write data for \"#{initials}\" to #{dest||'stdout'}\n\n"

initials.each do |one|
  output = ''
  query = "initial=#{one}"
  while (query)
    doc = fetch_page(query)
    output << get_data(doc) << "\n"
    query = get_next_query(doc)
  end

  puts "Writing #{output.size} characters"
  if dest
    File.open(dest, 'a') {|f| f.write(output) }
  else
    puts "\n"+output+"\n"
  end
  
end



