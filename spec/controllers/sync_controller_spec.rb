require 'rails_helper'

RSpec.describe SyncController, type: :controller do

  describe "GET #betapro" do
    it "returns http success" do
      get :betapro
      expect(response).to have_http_status(:success)
    end
  end

end
