require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  let!(:user) { FactoryBot.create(:user, email: 'test1234@test.com') }

  describe 'POST #create' do
    context 'when already logged in' do
      it "redirects to /" do
        sign_in user
        post :create, params: { password_reset: { email: 'test1234@test.com' } }
        expect(response).to redirect_to('/')
      end
    end

    context 'when not logged in' do
      context 'when email is not found' do
        it 'renders new' do
          post :create, params: { password_reset: { email: 'sam12345@test.com' } }
          expect(flash[:alert]).to be_present
          expect(response).to render_template('new')
        end
      end

      context 'when email is found' do
        it 'redirects to /login' do
          post :create, params: { password_reset: { email: 'test1234@test.com' } }
          expect(flash[:notice]).to be_present
          expect(response).to redirect_to('/login')
        end

        it 'sends email' do
          expect { post :create, params: { password_reset: { email: 'test1234@test.com' } } }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end
    end
  end

  describe 'PATCH #update' do
    before do
      post :create, params: { password_reset: { email: 'test1234@test.com' } }
      @reset_token = assigns(:user).reset_token
    end

    context 'success' do
      it 'redirect_to /login' do
        patch :update, params: { id: @reset_token, email: user.email, user: { password: 'password', password_confirmation: 'password' } }
        expect(flash[:success]).to be_present
        expect(response).to redirect_to('/login')
      end
    end

    context 'error' do
      context 'time expired' do
        let(:time) { 7.hours.ago }

        before { allow_any_instance_of(User).to receive(:reset_token_sent_at).and_return(time) }

        it "redirect_to /login" do
          patch :update, params: { id: @reset_token, email: user.email, user: { password: 'password', password_confirmation: 'password' } }
          expect(flash[:alert]).to be_present
          expect(response).to redirect_to('/login')
        end
      end

      context 'wrong token' do
        it "redirect_to /login" do
          patch :update, params: { id: 'test123', email: user.email, user: { password: 'password', password_confirmation: 'password' } }
          expect(flash[:alert]).to be_present
          expect(response).to redirect_to('/login')
        end
      end

      context 'wrong email' do
        it "redirect_to /login" do
          patch :update, params: { id: @reset_token, email: 'sam@dut.com', user: { password: 'password', password_confirmation: 'password' } }
          expect(flash[:alert]).to be_present
          expect(response).to redirect_to('/login')
        end
      end

      context 'password is missing' do
        it 'renders show' do
          patch :update, params: { id: @reset_token, email: user.email, user: { password: '', password_confirmation: '' } }
          expect(assigns(:user).errors).to be_present
          expect(response).to render_template('show')
        end
      end

      context 'password is short' do
        it 'renders show' do
          patch :update, params: { id: @reset_token, email: user.email, user: { password: 'pass', password_confirmation: 'pass' } }
          expect(assigns(:user).errors).to be_present
          expect(response).to render_template('show')
        end
      end

      context 'password mismatch' do
        it 'renders show' do
          patch :update, params: { id: @reset_token, email: user.email, user: { password: 'password', password_confirmation: 'password123' } }
          expect(assigns(:user).errors).to be_present
          expect(response).to render_template('show')
        end
      end
    end
  end

  describe "GET #new" do
    context 'when already logged in' do
      it "redirects to /" do
        sign_in user
        get :new
        expect(response).to redirect_to('/')
      end
    end

    context 'when not logged in' do
      it "returns http success" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #show" do
    before do
      post :create, params: { password_reset: { email: 'test1234@test.com' } }
      @reset_token = assigns(:user).reset_token
    end

    context 'when already logged in' do
      it "redirects to /login" do
        sign_in user
        get :show, params: { id: @reset_token, email: user.email }
        expect(response).to redirect_to('/')
      end
    end

    context 'success' do
      context 'when not logged in' do
        it "returns http success" do
          get :show, params: { id: @reset_token, email: user.email }
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'error' do
      context 'time expired' do
        let(:time) { 7.hours.ago }

        before { allow_any_instance_of(User).to receive(:reset_token_sent_at).and_return(time) }

        it "redirect_to /login" do
          get :show, params: { id: @reset_token, email: user.email }
          expect(flash[:alert]).to be_present
          expect(response).to redirect_to('/login')
        end
      end

      context 'wrong token' do
        it "redirect_to /login" do
          get :show, params: { id: 'test123', email: user.email }
          expect(flash[:alert]).to be_present
          expect(response).to redirect_to('/login')
        end
      end

      context 'wrong email' do
        it "redirect_to /login" do
          get :show, params: { id: @reset_token, email: 'sam@dut.com' }
          expect(flash[:alert]).to be_present
          expect(response).to redirect_to('/login')
        end
      end
    end
  end
end
