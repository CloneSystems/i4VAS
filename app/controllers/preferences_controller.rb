class PreferencesController < ApplicationController
  def index
    @preferences = Preference.all
  end

  def show
    @preference = Preference.find(params[:id])
  end

  def new
    @preference = Preference.new
  end

  def create
    @preference = Preference.new(params[:preference])
    if @preference.save
      redirect_to @preference, :notice => "Successfully created preference."
    else
      render :action => 'new'
    end
  end

  def edit
    @preference = Preference.find(params[:id])
  end

  def update
    @preference = Preference.find(params[:id])
    if @preference.update_attributes(params[:preference])
      redirect_to @preference, :notice  => "Successfully updated preference."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @preference = Preference.find(params[:id])
    @preference.destroy
    redirect_to preferences_url, :notice => "Successfully destroyed preference."
  end
end
