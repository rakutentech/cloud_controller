require "uaa/token_coder"
require "uaa/token_issuer"

class UaaToken

  @uaa_token_coder ||= CF::UAA::TokenCoder.new(AppConfig[:uaa][:resource_id],
                                               AppConfig[:uaa][:token_secret])

  @token_issuer ||= CF::UAA::TokenIssuer.new(AppConfig[:uaa][:url],
                                             AppConfig[:uaa][:resource_id],
                                             AppConfig[:uaa][:client_secret])

  @id_token_issuer ||= CF::UAA::TokenIssuer.new(AppConfig[:uaa][:url],
                                               "vmc",
                                               nil)

  class << self

    def is_uaa_token?(token)
      token.nil? || /\s+/.match(token.strip()).nil?? false : true
    end

    def decode_token(auth_token)
      if (auth_token.nil?)
        return nil
      end

      CloudController.logger.debug("uaa token coder #{@uaa_token_coder.inspect}")
      CloudController.logger.debug("Auth token is #{auth_token.inspect}")

      token_information = nil
      begin
        token_information = @uaa_token_coder.decode(auth_token)
        CloudController.logger.info("Token received from the UAA #{token_information.inspect}")
      rescue => e
        CloudController.logger.error("Invalid bearer token Message: #{e.message}")
      end
      token_information[:email] if token_information
    end

    def expired?(access_token)
      expiry = CF::UAA::TokenCoder.decode(access_token.split()[1], AppConfig[:uaa][:token_secret])[:expires_at]
      expiry.is_a?(Integer) && expiry <= Time.now.to_i
    end

    def expire_access_token
      @access_token = nil
      @user_account = nil
    end

    def access_token
      if @access_token.nil? || expired?(@access_token)
        #Get a new one
        @token_issuer.async = true
        @token_issuer.debug = true
        @token_issuer.logger = CloudController.logger
        @access_token = @token_issuer.client_credentials_grant().auth_header
      end
      CloudController.logger.debug("access_token #{@access_token}")
      @access_token
    end

    def id_token(email, password)
      @id_token_issuer.async = true
      @id_token_issuer.debug = true
      @id_token_issuer.logger = CloudController.logger
      id_token = @id_token_issuer.implicit_grant_with_creds(username: email, password: password).auth_header
      CloudController.logger.debug("id_token #{id_token}")
      id_token
    end

    def user_account_instance
      if @user_account.nil?
        @user_account = CF::UAA::UserAccount.new(AppConfig[:uaa][:url], UaaToken.access_token, true)
        @user_account.async = true
        @user_account.logger = CloudController.logger
      end
      @user_account
    end

  end

end
