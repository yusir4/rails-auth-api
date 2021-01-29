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

    private
    def user_params
      params.permit(:name, :surname, :email, :password)
    end
  
end
