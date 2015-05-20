require 'sinatra'
require 'config_env'
require 'protected_attributes'
require_relative './model/credit_card'
require_relative './model/user'
require_relative './helpers/creditcard_helper'

# Credit Card Web Service
class CreditCardAPI < Sinatra::Base
  include CreditCardHelper
  use Rack::Session::Cookie, secret: ENV['MSG_KEY']
  enable :logging

  configure :development, :test do
    require 'hirb'
    Hirb.enable


    ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
  end

  before do
    @current_user = session[:auth_token] ? find_user_by_token(session[:auth_token]) : nil
  end


  get '/' do
    # 'The CreditCardAPI is up and running!'
    haml :index
  end

  get '/api/v1/credit_card/validate' do
    c = CreditCard.new(
      number: params[:card_number]
    )

    # Method to convert string to integer
    # Returns false if string is not only digits
    result = Integer(params[:card_number]) rescue false

    # Validate for string length and correct type
    if result == false || params[:card_number].length < 2
      return {"Card" => params[:card_number], "validated" => "false"}.to_json
    end

    {"Card" => params[:card_number], "validated" => c.validate_checksum}.to_json
  end

  post '/api/v1/credit_card' do
    request_json = request.body.read
    req = JSON.parse(request_json)
    creditcard = CreditCard.new(
      number: req['number'],
      expiration_date: req['expiration_date'],
      owner: req['owner'],
      credit_network: req['credit_network']
    )

    begin
      unless creditcard.validate_checksum
        halt 400
      else
        creditcard.save
        status 201
      end
    rescue
      halt 410
    end
  end

  get '/api/v1/get' do
    begin
      creditcards = CreditCard.all.to_json
    rescue
      halt 500
    end
  end

  get '/register' do
    haml :register
  end

  post '/register' do
    logger.info('Register')
    username = params[:username]
    fullname = params[:fullname]
    email = params[:email]
    address = params[:address]
    password = params[:password]
    dob = params[:dob]
    password_confirm = params[:password_confirm]
    begin
      if password == password_confirm
        new_user = User.new(username: username, email: email)
        new_user.password = password
        new_user.address = new_user.attribute_encrypt(address)
        new_user.fullname = new_user.attribute_encrypt(fullname)
        new_user.dob = new_user.attribute_encrypt(dob)
        new_user.save! ? login_user(new_user) : fail('Could not create a new user')
      else
        fail 'Passwords do not match'
      end
    rescue => e
      logger.error(e)
      redirect '/register'
    end
  end

  get '/login' do
    haml :login
  end

  post '/login' do
    username = params[:username]
    password = params[:password]
    user = User.authenticate!(username, password)
    user ? login_user(user) : redirect('/login')
  end

  get '/logout' do
    session[:auth_token] = nil
    redirect '/'
  end

end
