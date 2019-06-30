require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { FactoryBot.create(:user, email: 'test1234@test.com') }

  describe "GET #new" do
    context 'when user is already logged in' do
      it "returns http success" do
        sign_in user
        get :new
        expect(response).to redirect_to('/')
      end
    end

    context 'when user is not logged in' do
      it "returns http success" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #show" do
    context 'when user is logged in' do
      before { sign_in user }

      it "returns http success" do
        get :show, params: { id: user.username }
        expect(response).to have_http_status(:success)
      end

      context 'when accessing other users profile page' do
        let(:user2) { FactoryBot.create(:user, email: 'test123@test.com') }
        it "returns redirects to root_path" do
          get :show, params: { id: user2.username }
          expect(response).to redirect_to('/')
        end
      end
    end

    context 'when user is not logged in' do
      it "returns http success" do
        get :show, params: { id: user.username }
        expect(response).to redirect_to('/login')
      end
    end
  end

  describe 'PATCH #update' do
    context 'when user is not logged in' do
      it "returns http success" do
        patch :update, params: { id: user.id, user: { username: 'test12345', password: 'password', password_confirmation: 'password' } }
        expect(response).to redirect_to('/login')
      end
    end

    context 'when logged in' do
      before { sign_in user }

      context 'success' do
        it "returns http success" do
          patch :update, params: { id: user.id, user: { username: 'test12345', password: 'password', password_confirmation: 'password' } }
          expect(assigns(:user).errors).to be_blank
          expect(response).to redirect_to('/users/test12345')
        end
      end

      context 'error' do
        context 'missing username' do
          it 'should render show with errors' do
            patch :update, params: { id: user.id, user: { username: '', password: 'password', password_confirmation: 'password' } }
            expect(assigns(:user).errors).to be_present
            expect(response).to render_template('show')
          end
        end

        context 'short username' do
          it 'should render show with errors' do
            patch :update, params: { id: user.id, user: { username: 'sam', password: 'password', password_confirmation: 'password' } }
            expect(assigns(:user).errors).to be_present
            expect(response).to render_template('show')
          end
        end

        context 'missing password' do
          it 'should render show with errors' do
            patch :update, params: { id: user.id, user: { username: 'sam12345', password: '', password_confirmation: '' } }
            expect(assigns(:user).errors).to be_present
            expect(response).to render_template('show')
          end
        end

        context 'password mismatch' do
          it 'should render show with errors' do
            patch :update, params: { id: user.id, user: { username: 'sam12345', password: 'password', password_confirmation: 'passwor' } }
            expect(assigns(:user).errors).to be_present
            expect(response).to render_template('show')
          end
        end

        context 'small password length' do
          it 'should render show with errors' do
            patch :update, params: { id: user.id, user: { username: 'sam12345', password: 'pass', password_confirmation: 'pass' } }
            expect(assigns(:user).errors).to be_present
            expect(response).to render_template('show')
          end
        end
      end
    end
  end

  describe "POST #create" do
    context 'success' do
      it "returns http success" do
        post :create, params: { user: { email: 'test123@test.com', password: 'password', password_confirmation: 'password' } }
        expect(assigns(:user).errors).to be_blank
        expect(response).to redirect_to('/users/test123')
      end

      it "sends wlecome email" do
        expect { post :create, params: { user: { email: 'test123@test.com', password: 'password', password_confirmation: 'password' } } }.to change{ ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'errors' do
      context 'missing email' do
        it 'should render new with errors' do
          post :create, params: { user: { email: '', password: 'password', password_confirmation: 'password' } }
          expect(assigns(:user).errors).to be_present
          expect(response).to render_template('new')
        end
      end
      context 'invalid email' do
        it 'should render new with errors' do
          post :create, params: { user: { email: 'test.com', password: 'password', password_confirmation: 'password' } }
          expect(assigns(:user).errors).to be_present
          expect(response).to render_template('new')
        end
      end
      context 'missing password' do
        it 'should render new with errors' do
          post :create, params: { user: { email: 'test123@test.com', password: '', password_confirmation: '' } }
          expect(assigns(:user).errors).to be_present
          expect(response).to render_template('new')
        end
      end
      context 'password mismatch' do
        it 'should render new with errors' do
          post :create, params: { user: { email: 'test123@test.com', password: 'password', password_confirmation: 'passwor' } }
          expect(assigns(:user).errors).to be_present
          expect(response).to render_template('new')
        end
      end
      context 'small password length' do
        it 'should render new with errors' do
          post :create, params: { user: { email: 'test123@test.com', password: 'pass', password_confirmation: 'pass' } }
          expect(assigns(:user).errors).to be_present
          expect(response).to render_template('new')
        end
      end
    end
  end
end
