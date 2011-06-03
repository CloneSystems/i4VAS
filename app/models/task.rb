class Task

  include OpenvasModel

  attr_accessor :name, :comment, :overall_progress, :status, :trend, :threat,
                :config_id, :config_name, :target_id, :target_name, :times_run,
                :schedule_id, :schedule_name,
                :first_report_id, :first_report_date,
                :last_report_id, :last_report_date,
                :last_report_debug, :last_report_high, :last_report_low, :last_report_log, :last_report_medium

  validates :comment, :length => { :maximum => 400 }
  validates :name, :presence => true, :length => { :maximum => 80 }

  def self.version(connection)
    req = Nokogiri::XML::Builder.new { |xml| xml.get_version }
    resp = connection.sendrecv(req.doc)
    ret = extract_value_from("/get_version_response/version", resp)
    ret
  end

  def self.from_xml_node(node)
    t = Task.new
    t.id                  = extract_value_from("@id", node)
    t.name                = extract_value_from("name", node)
    t.comment             = extract_value_from("comment", node)
    t.status              = extract_value_from("status", node)
    t.overall_progress    = extract_value_from("progress", node)
    # if node.at_xpath("progress")
    #   t.progress = VasTaskProgress.from_xml_node(node.at_xpath("progress"))
    # end
    t.times_run           = extract_value_from("report_count/finished", node).to_i
    t.trend               = extract_value_from("trend", node)
    t.last_report_id      = extract_value_from("last_report/report/@id", node)
    t.last_report_date    = extract_value_from("last_report/report/timestamp", node)
    t.last_report_debug   = extract_value_from("last_report/report/result_count/debug", node).to_i
    t.last_report_high    = extract_value_from("last_report/report/result_count/hole", node).to_i
    t.last_report_low     = extract_value_from("last_report/report/result_count/info", node).to_i
    t.last_report_log     = extract_value_from("last_report/report/result_count/log", node).to_i
    t.last_report_medium  = extract_value_from("last_report/report/result_count/warning", node).to_i
    t.first_report_id     = extract_value_from("first_report/report/@id", node)
    t.first_report_date   = extract_value_from("first_report/report/timestamp", node)
    t.config_id           = extract_value_from("config/@id", node)
    t.config_name         = extract_value_from("config/name", node)
    t.target_id           = extract_value_from("target/@id", node)
    t.target_name         = extract_value_from("target/name", node)
    t.schedule_id         = extract_value_from("schedule/@id", node)
    t.schedule_name       = extract_value_from("schedule/name", node)
    # node.xpath("reports/report").each { |xr|
    #   t.reports << VasReport.new({
    #     :id => extract_value_from("@id", xr),
    #     :started_at => extract_value_from("timestamp", xr)
    #   })
    # }
    t
  end

  def self.all(user, options = {})
    params = {:apply_overrides => 0, :sort_field => "name"}
    params[:task_id] = options[:id] if options[:id]
    params[:details] = 1
    cmd = Nokogiri::XML::Builder.new { |xml| xml.get_tasks(params) }
    tasks = user.openvas_connection.sendrecv(cmd.doc)
    ret = []
    begin
      tasks.xpath('//task').each { |t| ret << from_xml_node(t) }
    rescue
      raise XMLParsingError
    end
    ret
  end

  def self.find(id, user)
    return nil if id.blank? || user.blank?
    f = self.all(user, {:id=>id, :tasks=>1}).first
    # f = self.all(user, :id => id).first
    return nil if f.blank?
    # ensure "first" has the desired id:
    if f.id.to_s == id.to_s
      return f
    else
      return nil
    end
  end

  def save(user)
    if valid?
      vt = Task.find(self.id, user) # for update action
      vt = Task.new if vt.blank? # for create action
      vt.name = self.name
      vt.comment = self.comment
      vt.schedule_id  = self.schedule_id
      # note: openvas doesn't allow updates to config_id and target_id, only name and comment:
      if vt.new_record?
        vt.config_id    = self.config_id
        vt.target_id    = self.target_id
      end
      vt.create_or_update(user)
      vt.errors.each do |attribute, msg|
        self.errors.add(:openvas, "<br />" + msg)
      end
      return false unless self.errors.blank?
      return true
    else
      return false
    end
  end

  def update_attributes(user, attrs={})
    attrs.each { |key, value|
      send("#{key}=".to_sym, value) if public_methods.include?("#{key}=".to_sym)
    }
    save(user)
  end

  def create_or_update(user)
    # if schedule && schedule.changed?
    #   return unless schedule.save
    #   schedule_id = schedule.id
    # end
    # if config && config.changed?
    #   return unless config.save
    #   config_id = config.id
    # end
    req = Nokogiri::XML::Builder.new { |xml|
      if @id
        xml.modify_task(:task_id => @id) {
          xml.name    { xml.text(@name) }
          xml.comment { xml.text(@comment) }
          xml.schedule(:id => @schedule_id) unless @schedule_id.blank? || @schedule_id == '0'
        }
      else
        xml.create_task {
          xml.name    { xml.text(@name) }
          xml.comment { xml.text(@comment) } unless @comment.blank?
          xml.config(:id => @config_id)
          xml.target(:id => @target_id)
          xml.schedule(:id => @schedule_id) unless @schedule_id.blank? || @schedule_id == '0'
        }
      end
    }
    begin
      resp = user.openvas_connection.sendrecv(req.doc)
      @id = Task.extract_value_from("/create_task_response/@id", resp) unless @id
      true
    rescue Exception => e
      errors[:command_failure] << e.message
      nil
    end
  end

  def delete_record(user)
    req = Nokogiri::XML::Builder.new { |xml| xml.delete_task(:task_id => @id) }
    begin
      user.openvas_connection.sendrecv(req.doc)
      true
    rescue Exception => e
      errors[:command_failure] << e.message
      nil
    end
  end

  def threat
		# threat: High, Medium, Low, Log, Debug ... where Log,Debug are shown as None
		return '' if (@last_report_low + @last_report_medium + @last_report_high) == 0
		max = nil
		threat = ''
		low = @last_report_low
		max = low
		threat = 'Low'
		medium = @last_report_medium
		max = medium if medium >= max
		threat = 'Medium' if medium >= max
		high = @last_report_high
		max = high if high >= max
		threat = 'High' if high >= max
		threat = 'None' if threat == 0
		threat
  end

  def start(user)
    req = Nokogiri::XML::Builder.new { |xml| xml.resume_or_start_task(:task_id => @id) }
    user.openvas_connection.sendrecv(req.doc)
  end

  def stop(user)
    req = Nokogiri::XML::Builder.new { |xml| xml.stop_task(:task_id => @id) }
    user.openvas_connection.sendrecv(req.doc)
  end

  def pause(user)
    req = Nokogiri::XML::Builder.new { |xml| xml.pause_task(:task_id => @id) }
    user.openvas_connection.sendrecv(req.doc)
  end

  def resume_paused(user)
    req = Nokogiri::XML::Builder.new { |xml| xml.resume_paused_task(:task_id => @id) }
    user.openvas_connection.sendrecv(req.doc)
  end

  def resume_stopped(user)
    req = Nokogiri::XML::Builder.new { |xml| xml.resume_stopped_task(:task_id => @id) }
    user.openvas_connection.sendrecv(req.doc)
  end

end