class ApplicationController < ActionController::API
    before_action :authorized
    
    def auth_header
        # { Authorization: 'Bearer <token>' }
        request.headers['Authorization']
    end
    
    def encode_token(payload)
      JWT.encode(payload, 's3cr3t')
    end
    
    def decoded_token
      if auth_header
        token = auth_header.split(' ')[1]
        # header: { 'Authorization': 'Bearer <token>' }
        begin
          JWT.decode(token, 's3cr3t', true, algorithm: 'HS256')
        rescue JWT::DecodeError
          nil
        end
      end
    end
  
    def logged_in?
      if decoded_token
        if decoded_token[0]['expiration'] && Time.now < decoded_token[0]['expiration']
            # Access token süresi geçerli
            # Kullanıcı bilgilere erişebilir
            user_id = decoded_token[0]['user_id']
            @current_user = User.find_by(id: user_id)
          else 
            # Access token süresi bitmiş
            # Kullanıcı bilgilere erişemez
            render json: {
              status: "error",
              message: "Access Token Süresi doldu."
            }, status: :unauthorized
      
          end
      end
    end
  
    def authorized
      render json: {
        status: "error",
        message: "Access Token Giriniz."
      }, status: :unauthorized unless logged_in?
    end

end
