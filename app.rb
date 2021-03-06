require 'sinatra'
require 'config_env'
require 'rack-flash'
require 'json'
require 'protected_attributes'
require 'rack-flash'
require 'email_veracity'
require_relative './model/credit_card'
require_relative './model/user'
require_relative './helpers/creditcard_helper'

# Credit Card Web Service
class CreditCardAPI < Sinatra::Base
  include CreditCardHelper

  enable :logging

  configure do
    use Rack::Session::Cookie, secret: ENV['MSG_KEY']
    use Rack::Flash, :sweep => true
  end

  configure :development, :test do
    require 'hirb'
    Hirb.enable
    ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
  end

  configure do
    use Rack::Session::Cookie, secret: ENV['MSG_KEY']
    use Rack::Flash, :sweep => true
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
      return { "Card" => params[:card_number], "validated" => "false" }.to_json
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
    if token = params[:token]
      begin
        create_user_with_encrypted_token(token)
        flash[:notice] = "Your account has been successfully created."
      rescue
        flash[:error] = "Your account could not be created. Your link is either expired or invalid."
      end
      redirect '/'
    else
      haml(:register)
    end
  end

  post '/register' do
    logger.info('Register')
    registration = Registration.new(params)
    if (registration.complete?) != true
      flash[:error]= "Please fill in ALL fields."
      redirect '/register'
    elsif (params[:password] == params[:password_confirm]) != true
      flash[:error]= "Please ensure that the passwords are the SAME."
      redirect '/register'
    elsif EmailVeracity::Address.new(params[:email]).valid? != true
      flash[:error]= "Please enter a valid email address."
      redirect '/register'
    elsif user_available(params[:username]) != nil
      flash[:error]= "This username is not available."
      redirect '/register'
    else
      begin
        email_registration_verification(registration)
        flash[:notice] = "A verification link has been sent to #{params[:email]}. Please check your email!"
        redirect '/'
      rescue => e
        logger.error "FAIL EMAIL: #{e}"
      end
    end
  end

  get '/login' do
    haml :login
  end

  post '/login' do
    username = params[:username]
    password = params[:password]
    user = User.authenticate!(username, password)
    if user
      login_user(user)
    else
      flash[:error] = "Incorrect username or password!"
      redirect('/login')
    end
  end

  get '/logout' do
    session[:auth_token] = nil
    flash[:notice] = "You have successfully logged out."
    redirect '/'
  end

  get '/retrieve' do
    haml :retrieve
  end

  get '/validate' do
    haml :validate
  end

  get '/store' do
    haml :store
  end
end
