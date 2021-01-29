class UsersController < ApplicationController

    # Kayıt Ol
    # Girdi - email, password
    # Çıktı - user
    def create
      existing_user = User.find_by(email: params[:email])
      if existing_user
        render json: {error: "Kullanıcı Zaten Kayıtlı."}
      else
        @user = User.create(user_params)
        if @user.valid?
          render json: { user: @user }
        else
          render json: {error: "Geçersiz İşlem."}
        end
      end
    end

    # Giriş Yap
    # Girdi - email, password
    # Çıktı - refresh_token
    def login
        @user = User.find_by(email: params[:email])
        if @user && @user.authenticate(params[:password])
          refresh_token_control(@user)
          render json: {refresh_token: @user.refresh_token}
        else
          render json: {error: "Email veya şifre hatalıdır."}
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
    
    def new_refresh_token(user)
      exp_time = Time.now + 180*24*60*60
      token = JWT.encode({user_id: user.id, expiration: exp_time, type: "refresh_token"}, 's3cr3t')
    end

    private
    def user_params
      params.permit(:name, :surname, :email, :password)
    end
  
end
