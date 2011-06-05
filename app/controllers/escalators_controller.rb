class EscalatorsController < ApplicationController

  before_filter :redirect_to_root, :only => [:edit, :update]

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  def index
    @escalators = Escalator.all(current_user)
  end

  def show
    @escalator = Escalator.find(params[:id])
  end

  def new
    @escalator = Escalator.new
    # 1. Name<input type="text" name="name" value="unnamed" size="30" maxlength="80">
    # 2. Comment (optional)<input type="text" name="comment" size="30" maxlength="400">
    # 3. Event
    # <input type="radio" name="event" value="Task run status changed" checked>
    # Task run status changed to
    # <select name="event_data:status">
    # <option value="Delete Requested">Delete Requested</option>
    # <option value="Done" selected>Done</option>
    # <option value="New">New</option>
    # <option value="Requested">Requested</option>
    # <option value="Running">Running</option>
    # <option value="Stop Requested">Stop Requested</option>
    # <option value="Stopped">Stopped</option></select>
    # 4. Condition
    # <input type="radio" name="condition" value="Always" checked>
    # Always
    # <input type="radio" name="condition" value="Threat level at least">
    # Threat level is at least
    # <select name="condition_data:level">
    # <option value="High" selected>High</option>
    # <option value="Medium">Medium</option>
    # <option value="Low">Low</option>
    # <option value="Log">Log</option></select>
    # <input type="radio" name="condition" value="Threat level changed">
    # Threat level
    # <select name="condition_data:direction">
    # <option value="changed" selected>changed</option>
    # <option value="increased">increased</option>
    # <option value="decreased">decreased</option></select>
    # 
    # 5. Method
    # <input type="radio" name="method" value="Email" checked>
    # Email
    # To Address<input type="text" name="method_data:to_address" size="30" maxlength="301">
    # From Address<input type="text" name="method_data:from_address" size="30" maxlength="301">
    # 
    # Content
    # <input type="radio" name="method_data:notice" value="1" checked>
    # Simple notice
    # 
    # <input type="radio" name="method_data:notice" value="0">
    # Include report
    # <select name="method_data:notice_report_format">
    # <option value="a0704abb-2120-489f-959f-251c9f4ffebd">CPE</option>
    # <option value="b993b6f5-f9fb-4e6e-9c94-dd46c00e058d">HTML</option>
    # <option value="929884c6-c2c4-41e7-befb-2f6aa163b458">ITG</option>
    # <option value="9f1ab17b-aaaa-411a-8c57-12df446f5588">LaTeX</option>
    # <option value="f5c2a364-47d2-4700-b21d-0a7693daddab">NBE</option>
    # <option value="19f6f1b3-7128-4433-888c-ccc764fe6ed5" selected>TXT</option>
    # <option value="d5da9f67-8551-4e51-807b-b6a873d70e34">XML</option></select>
    # 
    # <input type="radio" name="method" value="syslog syslog">
    # System Logger (Syslog)</td></tr></table></td>
    # 
    # <input type="radio" name="method" value="syslog SNMP">
    # SNMP</td></tr></table></td>
    # 
    # <input type="radio" name="method" value="HTTP Get">
    # HTTP Get
    # URL
    # <input type="text" name="method_data:URL" size="30" maxlength="301">
  end

  def create
    @escalator = Escalator.new(params[:escalator])
    if @escalator.save
      redirect_to @escalator, :notice => "Successfully created escalator."
    else
      render :action => 'new'
    end
  end

  def edit
    @escalator = Escalator.find(params[:id])
  end

  def update
    @escalator = Escalator.find(params[:id])
    if @escalator.update_attributes(params[:escalator])
      redirect_to @escalator, :notice  => "Successfully updated escalator."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @escalator = Escalator.find(params[:id])
    @escalator.destroy
    redirect_to escalators_url, :notice => "Successfully destroyed escalator."
  end

end