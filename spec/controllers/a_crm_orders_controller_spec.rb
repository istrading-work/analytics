require 'rails_helper'

RSpec.describe ACrmOrdersController, type: :controller do

  describe "GET #russian_post" do
    it "returns http success" do
      get :russian_post
      expect(response).to have_http_status(:success)
    end
  end

end
