class CredentialsController < ApplicationController

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  # GET /download_public_key/1
  def download_public_key
    cred = Credential.find(params[:id], current_user)
    public_key = Credential.find_public_key_for_id(params[:id], current_user)
    if public_key.blank?
      flash[:error] = "SSH Public Key is empty for credential #{cred.name}."
      redirect_to credentials_url
    else
      send_data public_key, :type => 'application/key', :filename => "openvas-lsc-#{cred.name}.pub", :disposition => 'attachment'
    end
  end

  # GET /download_format/1
  def download_format
    cred = Credential.find(params[:id], current_user)
    package = Credential.find_format_for_id(params[:id], current_user, params[:credential_format])
    if package.blank?
      flash[:error] = "#{params[:credential_format].upcase} package is empty for credential #{cred.name}."
      redirect_to credentials_url
    else
      send_data package, :type => 'application/#{params[:credential_format].downcase}', :filename => "openvas-lsc-#{cred.name}.#{params[:credential_format].downcase}", :disposition => 'attachment'
    end
  end

  def index
    @credentials = Credential.all(current_user)
  end

  def show
    redirect_to credentials_url
    # @credential = Credential.find(params[:id], current_user)
  end

  def new
    @credential = Credential.new
    @credential.persisted = false
  end

  def create
    @credential = Credential.new(params[:credential])
    @credential.persisted = false
    if @credential.save(current_user)
      redirect_to credentials_url, :notice => "Successfully created credential."
    else
      render :action => 'new'
    end
  end

  def edit
    @credential = Credential.find(params[:id], current_user)
    @credential.persisted = true
# Rails.logger.info "class.methods=#{Credential.public_methods.sort.to_yaml}"
# @credential.attributes.each do |k, v|
#   Rails.logger.info "*name=#{k} | value=#{v.value} | datatype=#{v.datatype}"
#   # case v.datatype
#   # when "string"
#   #   f.text_field k
#   # when "text"
#   #   f.text_area k
#   # when "password"
#   #   f.password_field k
#   # end
# end
  end

  def update
    @credential = Credential.find(params[:id], current_user)
    @credential.persisted = true
    if @credential.update_attributes(current_user, params[:credential])
      redirect_to credentials_url, :notice  => "Successfully updated credential."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @credential = Credential.find(params[:id], current_user)
    @credential.delete_record(current_user)
    redirect_to credentials_url, :notice => "Successfully deleted credential."
  end

end