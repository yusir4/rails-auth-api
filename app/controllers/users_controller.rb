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
    def login
      if params[:email]
        # Email parametresi geldiyse refresh_token döndür.
        @user = User.find_by(email: params[:email])
        if @user && @user.authenticate(params[:password])
          refresh_token_control(@user)
          render json: {refresh_token: @user.refresh_token}
        else
          render json: {error: "Email veya şifre hatalıdır."}
        end
      elsif params[:refresh_token]
        # Refresh Token parametresi geldiyse access_token döndür.
        @user = User.find_by(refresh_token: params[:refresh_token])
        if @user
          access_token_control(@user)
          render json: {access_token: @user.access_token}
        else
          render json: {error: "Refresh Token hatalıdır.."}
        end
      else 
        # Email veya Refresh Token yoksa hata bildir.
        render json: {error: "Email veya Refresh Token eksik."}
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
    def user_params
      params.permit(:name, :surname, :email, :refresh_token, :access_token, :password)
    end
  
end
