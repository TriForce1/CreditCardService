require 'sinatra'
require_relative './lib/credit_card.rb'

# Credit Card Web Service
class CreditCardAPI < Sinatra::Base

  get '/api/v1/credit_card/validate' do
    c = CreditCard(params[:text],nil,nil,nil)
    {"Card" => params[text], "validated" => c.validate_checksum}.to_json
  end














end
