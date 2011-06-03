Warden::Strategies.add(:openvas_authentication_strategy) do

  def valid?
    true
  end

  def authenticate!
    return fail!('') if params[:controller].blank?
    return fail!('') unless params[:controller] == "devise/sessions"
    # user is trying to sign in so let's authenticate them:
    if params[:user]
      return fail!('') if params[:user][:username].blank?
      return fail!('') if params[:user][:password].blank?
      connection = openvas_authenticate(params[:user][:username], params[:user][:password])
      return fail!(:invalid) if connection.nil?
      if connection.logged_in?
        user = User.find_by_username(params[:user][:username])
        if user.blank?
          begin
            user = User.create!(:username=>params[:user][:username], :password=>params[:user][:password])
          rescue
            return fail!(:invalid)
          end
        else
          # note: user's password in openvas may have changed:
          user.password = params[:user][:password]
          user.save(:validate=>false)
        end
        # note: Devise encrypts this user's password in the database, but we may need the password 
        #       again in this user's session to authenticate with openvas as we send commands
        #       ... so let's cache it (***there has to be a more secure way***)
        Rails.cache.delete(user.username)
        Rails.cache.write(user.username, user.password)
        success!(user)
      else
        fail!(:invalid) # fail!('Invalid Sign In.')
      end 
    else
      fail!('')
    end
  end

  def openvas_authenticate(user, password)
    return false if user.blank? or password.blank?
    oc = Openvas::Connection.new("host"=>APP_CONFIG[:openvas_omp_host],"port"=>APP_CONFIG[:openvas_omp_port],"user"=>user,"password"=>password)
    oc.login
    oc = oc.logged_in? ? oc : nil
    return oc
  end

end