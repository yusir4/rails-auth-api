class UsersController < ApplicationController

  before_action :authorized, only: [:index, :show, :update, :destroy, :follow]

  ### USER RESTFUL START ###
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users/
  def index
    @users = User.select("id, name, surname, email").all
    render json: { 
      status: "success",
      data: {
        users: @users
      },
      message: 'Kullanıcılar başarılı bir şekilde listelendi.'
    }
  end

  # GET /users/1
  def show
    render json: { 
      status: "success",
      data: {
        user: { 
          name: @user.name,
          surname: @user.surname,
          email: @user.email
        }
      },
      message: 'Kullanıcı başarılı bir şekilde listelendi.'
    }
  end

  # POST /users/1
  # Kayıt Ol
  # Girdi - email, password
  # Çıktı - user
  def create
    existing_user = User.find_by(email: params[:email])
    if existing_user
      render json: {
        status: "error",
        data: {
          user: { 
            name: existing_user.name,
            surname: existing_user.surname,
            email: existing_user.email
            }
        },
        message: 'Kullanıcı zaten kayıtlı.'
      } 
    else
      @user = User.create(user_params)
      if @user.valid?
        render json: { 
          status: "success",
          data: {
            user: { 
              name: @user.name,
              surname: @user.surname,
              email: @user.email
            }
          },
          message: 'Kullanıcı başarılı bir şekilde kayıtlandı.'
        }
      else
        render json: {
          status: "error",
          message: @user.errors
        }
      end
    end
  end

  # PATCH/PUT /users/1
  def update
    @user.update(user_params)
      render json: { 
        status: "success",
        data: {
          user: { 
            name: @user.name,
            surname: @user.surname,
            email: @user.email
          }
        },
        message: 'Kullanıcı başarılı bir şekilde güncellendi.'
      }
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    render json: { 
      status: "success",
      message: 'Kullanıcı başarılı bir şekilde silindi.'
    }
  end

  ### USER RESTFUL END ###

  # GET /follow/1
  # Access Token sahibi Current Userdir. Takip edecek kişidir.
  # Takip edilecek kişi parametreden gelir.
  def follow
    follower = @current_user
    followed_user = User.find(params[:id])
  
    @follow = Follow.create(
      follower_id: follower.id,
      followed_user_id: followed_user.id,
      accepted: false
    )
    render json: { 
      status: "success",
      data: {
        follower: { 
          name: @current_user.name,
          surname: @current_user.surname,
          email: @current_user.email
        },
        followed_user: { 
          name: followed_user.name,
          surname: followed_user.surname,
          email: followed_user.email
        }
      },
      message: 'Başarılı bir şekilde istek gönderildi.'
    }
  end

  # Giriş Yap
  def login
    if params[:email]
      # Email parametresi geldiyse refresh_token döndür.
      @user = User.find_by(email: params[:email])
      if @user && @user.authenticate(params[:password])
        refresh_token_control(@user)
        render json: {
          status: "success",
          data: {
            refresh_token: @user.refresh_token
          },
          message: "Başarılı bir şekilde refresh token oluşturuldu."
        }
      else
        render json: {
          status: "error",
          message: "Email veya şifre hatalıdır."
        }
      end
    elsif params[:refresh_token]
      # Refresh Token parametresi geldiyse access_token döndür.
      @user = User.find_by(refresh_token: params[:refresh_token])
      if @user
        access_token_control(@user)
        render json: {
          status: "success",
          data: {
            access_token: @user.access_token
          },
          message: "Başarılı bir şekilde access token oluşturuldu."
        }
      else
        render json: {
          status: "error",
          message: "Refresh Token hatalıdır."
        }
      end
    else 
      # Email veya Refresh Token yoksa hata bildir.
      render json: {
        status: "error",
        message: "Email veya Refresh Token eksik."
      }
    end
  end

  def refresh_token_control(user)
    if user.refresh_token
      # Zamanını kontrol et
      decoded_refresh_token = JWT.decode(user.refresh_token, 's3cr3t', true, algorithm: 'HS256')
      
      if decoded_refresh_token[0]['expiration'] && Time.now < decoded_refresh_token[0]['expiration']
        # Refresh token süresi geçerli
      else 
        # Refresh token süresi bitmiş
        # Yeni token oluştur
        token = new_refresh_token(user)
        user.update(refresh_token: token)  
      end
    else
      # Yeni token oluştur
      token = new_refresh_token(user)
      user.update(refresh_token: token)
    end
  end
  
  # 180 gün (6 ay)
  def new_refresh_token(user)
    exp_time = Time.now + 180*24*60*60
    token = JWT.encode({user_id: user.id, expiration: exp_time, type: "refresh_token"}, 's3cr3t')
  end

  def access_token_control(user)
    if user.access_token
      # Zamanını kontrol et
      decoded_access_token = JWT.decode(user.access_token, 's3cr3t', true, algorithm: 'HS256')
      
      if decoded_access_token[0]['expiration'] && Time.now < decoded_access_token[0]['expiration']
        # Access token süresi geçerli
      else 
        # Access token süresi bitmiş
        # Yeni token oluştur
        token = new_access_token(user)
        user.update(access_token: token)  
      end
    else
      # Yeni token oluştur
      token = new_access_token(user)
      user.update(access_token: token)
    end
  end

  # 15 dakika
  def new_access_token(user)
    exp_time = Time.now + 15*60
    token = JWT.encode({user_id: user.id, expiration: exp_time, type: "access_token"}, 's3cr3t')
  end


  private
    def set_user
      begin
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          status: "error",
          message: "Böyle bir kayıt bulunamadı."
        }
    end
      
    end
    def user_params
      params.permit(:name, :surname, :email, :refresh_token, :access_token, :password)
    end
end
