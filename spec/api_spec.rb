require_relative 'spec_helper'

describe 'Credit Card API Test' do
  describe 'Getting Root of Credit Card API' do
    it 'should return status 200' do
      get '/'
      last_response.body.must_include 'up'
      last_response.status.must_equal 200
    end
  end

  describe 'Validation Route for Credit Card API' do
    before do
      CreditCard.delete_all
    end

    it 'Testing valid credit card on validation route' do
      get "/api/v1/credit_card/validate?card_number=4539075978941247"
      last_response.status.must_equal 200
      last_response.body.must_include 'validated'
      results =JSON.parse(last_response.body)
      results['validated'].must_equal true
    end

    it 'Testing for invalid validation route' do
      get "/api/v1/credit_card/valdate?card_number=4539075978941247"
      last_response.status.must_equal 404
    end

  end

end
