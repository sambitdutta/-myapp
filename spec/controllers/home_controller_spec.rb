require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    context 'with user signed in' do
      let(:user) { FactoryBot.create(:user) }

      it "returns http success" do
        sign_in user
        get :index
        expect(response).to have_http_status(:success)
        expect(response).to render_template('index')
      end
    end

    context 'when user is not signed in' do
      it "returns http success" do
        get :index
        expect(response).to redirect_to('/login')
      end
    end
  end
end
