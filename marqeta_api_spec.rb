require "httparty"

describe "Marqeta Sandbox and APIs" do
  let(:base_uri) { "https://shared-sandbox-api.marqeta.com/v3" }

  describe "Basic Setup" do
    it "Rspec works" do
      expect(1+1).to eq 2
    end

    it "Can detect the sandbox heartbeat" do
      uri = base_uri + "/ping"
      response = HTTParty.get(uri)
      expect(response["success"]).to be true
    end

  end


end
