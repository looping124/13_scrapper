class Scrapper


  def initialize
    link_departement = "https://www.annuaire-des-mairies.com/val-d-oise.html"
      # @cities_links_array=[{"Wy-dit-joli-village"=>"mairie.wy-dit-joli-village@wanadoo.fr"}]
       @cities_links_array = get_townhall_urls(link_departement)
    
         @cities_links_array.each do |cities_links_hash|
           cities_links_hash.each { |k, v| cities_links_hash[k] = get_townhall_email(cities_links_hash[k]) } 
          end
    return @cities_links_array
  end

  def save_as_csv()
    unless Dir.exist?('db') then Dit.new('db')end
    if File.exist?('db/emails.csv') then File.delete('db/emails.csv') end
    file_csv = CSV.open("db/emails.csv","w")
    
    CSV.open("myfile.csv", "w") do |csv|
      @cities_links_array.each do |row|
        csv << [row.keys.to_s.gsub("\"","").gsub("\[","").gsub("\]",""),row.values.to_s.gsub("\"","").gsub("\[","").gsub("\]","")]
    end
  end
  end

  def save_as_json()
    unless Dir.exist?('db') then Dit.new('db')end
      if File.exist?('db/emails.json') then File.delete('db/emails.json') end
      file_json = File.open("db/emails.json","w")
      file_json.write(@cities_links_array.to_json)
  end

  def save_as_spreadsheet()
    session = GoogleDrive::Session.from_config("config.json")
    ws = session.spreadsheet_by_key("1vtsT7-muRkP8EFt9vO_jKSe41md4wnEWQqfapSt2GfA").worksheets[0]
    ws[1, 1] = "Noms de ville"
    ws[1, 2] = "Adresses email"
    @cities_links_array.each_with_index do |element, index|
      ws[index+2,1] = @cities_links_array[index].keys.to_s.gsub("\"","").gsub("\[","").gsub("\]","")
      ws[index+2,2] = @cities_links_array[index].values.to_s.gsub("\"","").gsub("\[","").gsub("\]","")
    end
    ws.save
  end



  def get_townhall_email (link_city)
    page_ville = Nokogiri::HTML(URI.open(link_city)) 
    email = page_ville.xpath('/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]').text
    return email
  
  end


  def get_townhall_urls(link_departement) 

    page = Nokogiri::HTML(URI.open(link_departement))
    links = page.css(".lientxt")
    links_cities=  links.map {|element| element["href"]}.compact
    links_final_array =[]
    links_cities.each.with_index do |link, index|
      links_final_array[index] = {link.gsub("./95/", "").gsub(".html", "").capitalize =>"https://www.annuaire-des-mairies.com/"+link.gsub("./", "")}
    end
    return links_final_array
  end

end