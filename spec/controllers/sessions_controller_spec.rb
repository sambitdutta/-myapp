require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { FactoryBot.create(:user, email: 'sambit@dutta.com') }

  describe "GET #new" do
    context 'when user is logged in' do
      it "redirects" do
        sign_in double(User, id: 100)
        get :new
        expect(response).to redirect_to('/')
      end
    end
    context 'when no user is logged in' do
      it "returns http success" do
        get :new
        expect(response).to have_http_status(:success)
        expect(response).to render_template('sessions/new')
      end
    end
  end

  describe "POST #create" do
    context 'success' do
      it 'redirects to home page' do
        post :create, params: { login: { email: user.email, password: 'password' } }
        expect(response).to redirect_to('/')
      end
    end

    context 'failure' do
      context 'invalid user' do
        it 'renders new page' do
          post :create, params: { login: { email: 'test@test.com', password: 'password' } }
          expect(response).to render_template('new')
        end
      end

      context 'incorrect password' do
        it 'renders new page' do
          post :create, params: { login: { email: user.email, password: 'password123' } }
          expect(response).to render_template('new')
        end
      end
    end
  end

  describe "DELETE #destroy" do
    it "redirect to login" do
      sign_in user
      get :destroy
      expect(response).to redirect_to('/login')
    end
  end
end
