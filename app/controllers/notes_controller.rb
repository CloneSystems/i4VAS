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
    @note.report_id = params[:report_id]
    @note.task_id = params[:task_id]
    @note.task_name = params[:task_name]
    @note.result_id = params[:result_id]
    @note.result_description = params[:result_description]
    @note.nvt_oid = params[:nvt_oid]
    @note.hosts = params[:hosts]
    @note.port = params[:port]
    @note.threat = params[:threat]
    # https://192.168.1.4/omp?r=1&cmd=new_note
    # &result_hosts_only=1
    # &overrides=1
    # &notes=1
    # &hosts=127.0.0.1
    # &port=general/tcp
    # &threat=Low
    # &apply_min_cvss_base=false
    # &min_cvss_base=
    # &search_phrase=
    # &sort_order=descending
    # &sort_field=type
    # &levels=hml
    # &first_result=1
    # &report_id=f1bc8e10-8e5d-43d3-b2a5-e209546eec9b
    # &name=3%20at%20once
    # &task_id=0a2452f0-3aba-496c-9302-b62d9abcaeb4
    # &oid=1.3.6.1.4.1.25623.1.0.102002
    # &result_id=de7be789-036b-424c-8f60-2ec200891182
    # 
    # new Note with no OID:
    # https://192.168.1.4/omp?cmd=new_note
    # &result_id=751d2dd4-4cf1-4d46-b9c9-8d4b0afac336
    # &oid=0
    # &task_id=5e67b1e9-2a72-4b6c-b62b-7af71aefeea4
    # &name=spudder
    # &report_id=de557f48-9e10-4c13-ba67-60ab2ee83b33
    # &first_result=1
    # &levels=g
    # &sort_field=type
    # &sort_order=descending
    # &search_phrase=
    # &min_cvss_base=
    # &apply_min_cvss_base=false
    # &threat=Log
    # &port=otp%20(9390/tcp)
    # &hosts=127.0.0.1
    # &notes=1
    # &overrides=1
    # &result_hosts_only=1
    # 
    # https://192.168.1.4/omp?cmd=edit_note
    # &note_id=843fb74c-f412-46f8-b30c-923fd241b9ad
    # &next=get_report
    # &report_id=de557f48-9e10-4c13-ba67-60ab2ee83b33
    # &first_result=1
    # &sort_field=type
    # &sort_order=descending
    # &levels=hm
    # &notes=1
    # &overrides=1
    # &result_hosts_only=1
    # &search_phrase=
    # &min_cvss_base=
    # &apply_min_cvss_base=false
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
    redirect_to notes_url, :notice => "*** edit is under development ***"
    # @note = Note.find(params[:id], current_user)
    # @note.persisted = true
  end

  def update
    @note = Note.find(params[:id], current_user)
    @note.persisted = true
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