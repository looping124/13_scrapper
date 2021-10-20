require 'bundler'
Bundler.require

require_relative 'lib/scrapper'

toto = Scrapper.new
toto.save_as_csv
#binding.pry
