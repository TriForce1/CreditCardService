require 'sinatra'
require_relative './lib/credit_card.rb'

# Credit Card Web Service
class CreditCardAPI < Sinatra::Base

  get '/' do
    'The CreditCardAPI is up and running!'
  end

  get '/api/v1/credit_card/validate' do
    c = CreditCard.new(params[:card_number],nil,nil,nil)
    {"Card" => params[:card_number], "validated" => c.validate_checksum}.to_json
  end

end
