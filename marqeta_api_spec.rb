require "httparty"
require "pp"

describe "Marqeta Sandbox and APIs" do
  let(:base_uri) { "https://shared-sandbox-api.marqeta.com/v3" }
  let!(:auth) { {
    username: ENV["MARQETA_SANDBOX_APPLICATION_TOKEN"],
    password: ENV["MARQETA_SANDBOX_MASTER_ACCESS_TOKEN"]
  } }
  let!(:headers) { { "content-Type" => "application/json" } }
  let(:options) { { basic_auth: auth, headers: headers } }

  describe "Basic Setup" do
    it "Can detect the sandbox heartbeat" do
      uri = base_uri + "/ping"
      response = HTTParty.get(uri)
      expect(response["success"]).to be true
    end

    it "Can create a Card Product" do
      uri = base_uri + "/cardproducts"
      options[:body] =  {
        start_date: "2017-01-01",
        name: "Example Card Product",
        config: {
          fulfillment: { payment_instrument: "VIRTUAL_PAN" },
          poi: { ecommerce: true },
          card_life_cycle: { activate_upon_issue: true }
        }
      }.to_json
      response = HTTParty.post(uri, options).parsed_response
      expect(response["name"]).to eq "Example Card Product"
      expect(response["active"]).to be true
      expect(response["token"]).to_not be_nil
    end

    it "Can create a Program Funding Source" do
      uri = base_uri + "/fundingsources/program"
      options[:body] = { name: "Program Funding" }.to_json
      response = HTTParty.post(uri, options).parsed_response
      expect(response["name"]).to eq "Program Funding"
      expect(response["active"]).to be true
      expect(response["token"]).to_not be_nil
    end

    it "Can create a User" do
      uri = base_uri + "/users"
      options[:body] = {}.to_json
      response = HTTParty.post(uri, options).parsed_response
      expect(response["active"]).to be true
      expect(response["token"]).to_not be_nil
    end
  end

  describe "Cards" do
    let(:card_product_token) {
      uri = base_uri + "/cardproducts"
      options[:body] =  {
        start_date: "2017-01-01",
        name: "Example Card Product",
        config: {
          fulfillment: { payment_instrument: "VIRTUAL_PAN" },
          poi: { ecommerce: true },
          card_life_cycle: { activate_upon_issue: true }
        }
      }.to_json
      HTTParty.post(uri, options).parsed_response["token"]
    }
    let(:user_token) {
      uri = base_uri + "/users"
      options[:body] = {}.to_json
      HTTParty.post(uri, options).parsed_response["token"]
    }
    let(:funding_source_token) {
      uri = base_uri + "/fundingsources/program"
      options[:body] = { name: "Program Funding" }.to_json
      HTTParty.post(uri, options).parsed_response["token"]
    }

    it "Can create a new Card" do
      uri = base_uri + "/cards"
      options[:body] =  {
        card_product_token: card_product_token,
        user_token: user_token
      }.to_json
      response = HTTParty.post(uri, options).parsed_response
      expect(response["state"]).to eq "ACTIVE"
      expect(response["state_reason"]).to eq "New card activated"
      expect(response["fulfillment_status"]).to eq "ISSUED"
      expect(response["token"]).to_not be_nil
    end

    it "Can fund the User's GPA account" do
      uri = base_uri + "/gpaorders"
      options[:body] = {
        user_token: user_token,
        amount: "1000",
        currency_code: "USD",
        funding_source_token: funding_source_token
      }.to_json
      response = HTTParty.post(uri, options).parsed_response
      expect(response["amount"]).to eq 1000
      expect(response["token"]).to_not be_nil
    end

    describe "Unrestricted" do
      let(:card_token) {
        uri = base_uri + "/cards"
        options[:body] =  {
          card_product_token: card_product_token,
          user_token: user_token
        }.to_json
        HTTParty.post(uri, options).parsed_response["token"]
      }
      before(:each) {
        uri = base_uri + "/gpaorders"
        options[:body] = {
          user_token: user_token,
          amount: "1000",
          currency_code: "USD",
          funding_source_token: funding_source_token
        }.to_json
        HTTParty.post(uri, options)
      }

      it "Can simulate an authorization" do
        uri = base_uri + "/simulate/authorization"
        options[:body] = {
          amount: "97",
          mid: "1234567890",
          card_token: card_token
        }.to_json
        response = HTTParty.post(uri, options).parsed_response
        expect(response["transaction"]["amount"]).to eq 97
        expect(response["transaction"]["token"]).to_not be_nil
      end


    end
  end
end
