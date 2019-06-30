require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let!(:user) { FactoryBot.create(:user, email: 'sambd@test.com') }
  let!(:messages) { FactoryBot.build_list(:message, 3) }

  describe 'GET #index' do
    before do
      sign_in user
      user.messages = messages
    end

    it 'should be http success' do
      get :index, params: { user_id: user.username }
      expect(assigns(:messages).length).to eq(3)
      expect(response).to have_http_status(:success)
    end
  end
end
