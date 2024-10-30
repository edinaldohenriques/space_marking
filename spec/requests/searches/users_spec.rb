require 'rails_helper'

RSpec.describe "Searches::Users", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/searches/users/show"
      expect(response).to have_http_status(:success)
    end
  end

end
