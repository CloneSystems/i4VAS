class User < ActiveRecord::Base

  devise :database_authenticatable, :trackable, :timeoutable, :validatable

  attr_accessible :username, :email, :password, :password_confirmation

  def connection=(conn)
    @connection ||= conn
  end

  def connection
    @connection
  end

end