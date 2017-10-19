require "httparty"

describe "Marqeta Sandbox and APIs" do
  let(:base_uri) { "https://shared-sandbox-api.marqeta.com/v3" }
  let(:auth) { {
    username: ENV["MARQETA_SANDBOX_APPLICATION_TOKEN"],
    password: ENV["MARQETA_SANDBOX_MASTER_ACCESS_TOKEN"]
  } }

  describe "Basic Operation" do
    it "Can detect the sandbox heartbeat" do
      uri = base_uri + "/ping"
      response = HTTParty.get(uri)
      expect(response["success"]).to be true
    end

    it "Can create a Card Product" do
      uri = base_uri + "/cardproducts"
      headers = { "content-Type" => "application/json" }
      body =  {
        start_date: "2017-01-01",
        name: "Example Card Product",
        config: {
          fulfillment: {
            payment_instrument: "VIRTUAL_PAN"
          },
          poi: {
            ecommerce: true
          },
          card_life_cycle: {
            activate_upon_issue: true
          }
        }
      }.to_json
      response = HTTParty.post(uri, basic_auth: auth, headers: headers, body: body).parsed_response
      expect(response["name"]).to eq "Example Card Product"
      expect(response["active"]).to be true
    end

  end


end
