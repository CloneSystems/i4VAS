class FamiliesController < ApplicationController
  def index
    @families = Family.all
  end

  def show
    @family = Family.find(params[:id])
  end

  def new
    @family = Family.new
  end

  def create
    @family = Family.new(params[:family])
    if @family.save
      redirect_to @family, :notice => "Successfully created family."
    else
      render :action => 'new'
    end
  end

  def edit
    @family = Family.find(params[:id])
  end

  def update
    @family = Family.find(params[:id])
    if @family.update_attributes(params[:family])
      redirect_to @family, :notice  => "Successfully updated family."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @family = Family.find(params[:id])
    @family.destroy
    redirect_to families_url, :notice => "Successfully destroyed family."
  end
end
