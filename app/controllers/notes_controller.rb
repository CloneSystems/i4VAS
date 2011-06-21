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
    @note.persisted = false
    @note.report_id           = params[:report_id]
    @note.task_id             = params[:task_id]
    @note.task_name           = params[:task_name]
    @note.result_id           = params[:result_id]
    @note.result_description  = params[:result_description]
    @note.nvt_oid             = params[:nvt_oid]
    @note.hosts               = params[:hosts]
    @note.port                = params[:result_port]
    @note.threat              = params[:threat]
  end

  def create
    @note = Note.new(params[:note])
    @note.persisted = false
    if @note.save(current_user)
      redirect_to notes_url, :notice => "Successfully created note."
    else
      render :action => 'new'
    end
  end

  def edit
    @note = Note.find(params[:id], current_user)
    @note.persisted = true
    @note.task_name           = params[:task_name]
    @note.result_description  = params[:result_description]
    @note.hosts               = params[:hosts]
    @note.port                = params[:result_port]
    @note.threat              = params[:threat]
  end

  def update
    @note = Note.find(params[:id], current_user)
    @note.persisted = true
    if @note.update_attributes(current_user, params[:note])
      redirect_to notes_url, :notice  => "Successfully updated note."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @note = Note.find(params[:id], current_user)
    @note.delete_record(current_user)
    redirect_to notes_url, :notice => "Successfully deleted note."
  end

end