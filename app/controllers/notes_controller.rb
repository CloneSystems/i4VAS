class NotesController < ApplicationController

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  def index
    @notes = Note.all(current_user)
  end

  def show
    @note = Note.find(params[:id], current_user)
    @overrides = Note.debug_response(current_user)
  end

  def new
    @note = Note.new
  end

  def create
    @note = Note.new(params[:note])
    if @note.save
      redirect_to @note, :notice => "Successfully created note."
    else
      render :action => 'new'
    end
  end

  def edit
    redirect_to notes_url, :notice => "*** edit is under development ***"
    # @note = Note.find(params[:id], current_user)
  end

  def update
    @note = Note.find(params[:id], current_user)
    if @note.update_attributes(params[:note])
      redirect_to @note, :notice  => "Successfully updated note."
    else
      render :action => 'edit'
    end
  end

  def destroy
    redirect_to notes_url, :notice => "*** delete is under development ***"
    # @note = Note.find(params[:id], current_user)
    # @note.destroy
    # redirect_to notes_url, :notice => "Successfully destroyed note."
  end

end