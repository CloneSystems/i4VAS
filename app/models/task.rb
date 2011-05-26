class Task

  include BasicModel

  # note: since we are not using ActiveRecord for persistence, but ActiveModel instead, 
  #       we need to manually manipulate the return value for "persisted?" so that in 
  #       the views "form_for" will set the correct route and post/put action 
  #       ... i.e. use false for new/create actions, and true for edit/update actions:
  attr_accessor :persisted

  attr_accessor :id, :name, :comment, :overall_progress, :status, :trend, :threat,
                :config_id, :config_name, :target_id, :target_name, :times_run,
                :first_report_id, :first_report_date,
                :last_report_id, :last_report_date,
                :last_report_debug, :last_report_high, :last_report_low, :last_report_log, :last_report_medium

  validates :comment, :length => { :maximum => 400 }
  validates :name, :presence => true, :length => { :maximum => 80 }

  def persisted?
    @persisted || false
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
    # node.xpath("reports/report").each { |xr|
    #   t.reports << VasReport.new({
    #     :id => extract_value_from("@id", xr),
    #     :started_at => extract_value_from("timestamp", xr)
    #   })
    # }
    # t.reset_changes
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

  def self.find(id)
    vt = OpenvasCli::VasTask.get_by_id(id)
    dup_vastask_to_self(vt)
  end

  def self.find_as_vastask(id)
    return nil if id.blank?
    OpenvasCli::VasTask.get_by_id(id)
  end

  def save
    if valid?
      vt = Task.find_as_vastask(self.id) # for update action
      vt = OpenvasCli::VasTask.new if vt.blank? # for create action
      vt.name = self.name
      vt.comment = self.comment
      # note: openvas doesn't allow updates to config_id and target_id, only name and comment:
      if vt.new_record?
        vt.config_id = self.config_id
        vt.target_id = self.target_id
      end
      vt.create_or_update
      vt.errors.each do |attribute, msg|
        self.errors.add(:openvas, "<br />" + msg)
      end
      return false unless self.errors.blank?
      return true
    else
      return false
    end
  end

  def update_attributes(attrs={})
    attrs.each { |key, value|
      send("#{key}=".to_sym, value) if public_methods.include?("#{key}=".to_sym)
    }
    save
  end

  def destroy
    delete_record
  end

  def self.get_by_id(id)
    get_all(:id => id).first
  end

  def create_or_update
    true
  end

  def delete_record
    true
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

  private

  def self.dup_vastask_to_self(vt)
    Task.new({:id => vt.id, :name => vt.name, :comment => vt.comment, :status => vt.status,
              :trend => vt.trend, :overall_progress => vt.progress.overall,
              :times_run => vt.times_run,
              :first_report_id => vt.first_report_id, :first_report_date => vt.first_report_date,
              :last_report_id => vt.last_report_id, :last_report_date => vt.last_report_date,
              :last_report_result_count => vt.result_count,
              :config_id => vt.config_id, :target_id => vt.target_id,
              :config_name => vt.config_name, :target_name => vt.target_name
            })
  end

  # Helper method to extract a value from a Nokogiri::XML::Node object.  If the
  # xpath provided contains an @, then the method assumes that the value resides
  # in an attribute, otherwise it pulls the text of the last +text+ node.
  def self.extract_value_from(x_str, n)
    ret = ""
    return ret if x_str.nil? || x_str.empty?
    if x_str =~ /@/
      ret = n.at_xpath(x_str).value  if n.at_xpath(x_str)
    else
      tn =  n.at_xpath(x_str)
      if tn
        if tn.children.count > 0
          tn.children.each { |tnc|
            if tnc.text?
              ret = tnc.text
            end
          }
        else
          ret = tn.text
        end
      end
    end
    ret
  end

end