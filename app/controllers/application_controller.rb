class ApplicationController < ActionController::API
	def authenticate
    if !token_valid?
      render json: { status: false, message: 'unauthorized access / token' }, status: 401
    end
  end

  private
  def token_valid?
    if token_present?
      app = Session.find_by(:token => token)
      if app.present?
        if Time.parse(app.expired_time) < Time.now
          false
        else
          true
        end
      else
        false
      end
    else
      false
    end
  end

  def token
      request.env['HTTP_TOKEN'].scan(/Sahlun (.*)$/).flatten.last
  end

  def token_present?
      !!request.env.fetch('HTTP_TOKEN','').scan(/Sahlun/).flatten.first
  end
end
