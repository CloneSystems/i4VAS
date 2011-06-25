class ScanConfig

  include OpenvasModel

  attr_accessor :name, :comment, :family_count, :families_grow, :nvts_count, :nvts_grow, :in_use
  attr_accessor :tasks, :copy_id

  validates :name, :presence => true, :length => { :maximum => 80 }
  validates :comment, :length => { :maximum => 400 }

  def tasks
    @tasks ||= []
  end

  def nvt_preferences
    @nvt_preferences ||= []
  end

  def scanner_preferences
    @scanner_preferences ||= []
  end

  def families
    @families ||= []
  end

  def self.base_selections(user)
    return nil if user.nil?
    cfgs = []
    self.all(user).each do |o|
      cfgs << o if o.name.downcase == 'empty'
      cfgs << o if o.name.downcase == 'full and fast'
    end
    cfgs
  end

  def self.selections(user)
    return nil if user.nil?
    cfgs = []
    self.all(user).each do |o|
      cfgs << o unless o.name == 'empty' # ignore the 'empty'(base) scan config
    end
    cfgs
  end

  def self.export(id, user)
    params = { :export=>'1' }
    params[:config_id] = id if id
    req = Nokogiri::XML::Builder.new { |xml| xml.get_configs(params) }
    config_as_xml = user.openvas_connection.sendrecv(req.doc)
    config_as_xml
  end

  def self.all(user, options = {})
    params = {:sort_field  => "name"}
    if options[:show_details] && options[:show_details] == true
      params.merge!({:families => "1", :preferences => "1"})
    end    
    params[:config_id] = options[:id] if options[:id]
    req = Nokogiri::XML::Builder.new { |xml| xml.get_configs(params) }
    ret = []
    begin
      resp = user.openvas_connection.sendrecv(req.doc)
      # Rails.logger.info "\n\n resp=#{resp.to_xml.to_yaml}\n\n"
      resp.xpath("/get_configs_response/config").each { |xml|
        cfg               = ScanConfig.new
        cfg.id            = extract_value_from("@id", xml)
        cfg.name          = extract_value_from("name", xml)
        cfg.comment       = extract_value_from("comment", xml)
        cfg.family_count  = extract_value_from("family_count", xml).to_i
        cfg.families_grow = extract_value_from("family_count/growing", xml).to_i
        cfg.nvts_count    = extract_value_from("nvt_count", xml).to_i
        cfg.nvts_grow     = extract_value_from("nvt_count/growing", xml).to_i
        cfg.in_use        = extract_value_from("in_use", xml).to_i
        xml.xpath("tasks/task").each { |t|
          task      = Task.new
          task.id   = extract_value_from("@id", t)
          task.name = extract_value_from("name", t)
          cfg.tasks << task
        }
        xml.xpath("preferences/preference").each { |p|
          pref = Preference.new
          pref.config_id      = cfg.id
          pref.name           = extract_value_from("name", p)
          pref.value          = extract_value_from("value", p)
          pref.nvt_id         = extract_value_from("nvt/@oid", p)
          pref.nvt_name       = extract_value_from("nvt/name", p)
          pref.val_type_desc  = extract_value_from("type", p)
          if pref.nvt_name.blank?
            cfg.scanner_preferences << pref
          else
            cfg.nvt_preferences << pref
          end
        }
        xml.xpath("families/family").each { |f|
          family = Family.new
          family.name           = extract_value_from('name', f)
          family.nvt_count      = extract_value_from('nvt_count', f).to_i
          family.max_nvt_count  = extract_value_from('max_nvt_count', f).to_i
          family.growing        = extract_value_from("growing", f).to_i
          cfg.families << family
        }
        ret << cfg
      }
    rescue Exception => e
      raise e
    end
    ret
  end

  def self.find(params, user)
    return nil if params[:id].blank? || user.blank?
    f = self.all(user, params).first
    return nil if f.blank?
    # ensure "first" has the desired id:
    if f.id.to_s == params[:id].to_s
      return f
    else
      return nil
    end
  end

  def update_attributes(user, attrs={})
    # note modify(edit/update) is not implemented in OMP 2.0
    false
  end

  def save(user)
    # note: modify(edit/update) is not implemented in OMP 2.0
    if valid?
      sc = ScanConfig.new
      sc.name         = self.name
      sc.comment      = self.comment
      sc.copy_id      = self.copy_id
      sc.create_or_update(user)
      sc.errors.each do |attribute, msg|
        self.errors.add(:openvas, "<br />" + msg)
      end
      return false unless self.errors.blank?
      return true
    else
      return false
    end
  end

  def create_or_update(user)
    # note: modify(edit/update) is not implemented in OMP 2.0
    req = Nokogiri::XML::Builder.new { |xml|
      xml.create_config {
        xml.name    { xml.text(@name) }
        xml.comment { xml.text(@comment) } unless @comment.blank?
        xml.copy    { xml.text(@copy_id) }
      }
    }
    begin
      resp = user.openvas_connection.sendrecv(req.doc)
      if ScanConfig.extract_value_from("//@status", resp) =~ /20\d/
        @id = ScanConfig.extract_value_from("/create_config_response/@id", resp)
        true
      else
        msg = ScanConfig.extract_value_from("//@status_text", resp)
        raise msg
      end
    rescue Exception => e
      errors[:command_failure] << e.message
      nil
    end
  end

  def delete_record(user)
    req = Nokogiri::XML::Builder.new { |xml| xml.delete_config(:config_id => @id) }
    begin
      resp = user.openvas_connection.sendrecv(req.doc)
      true
    rescue Exception => e
      errors[:command_failure] << e.message
      nil
    end
  end

end
# 7.48.3 Example: Modify a config preference
# Client
#  <modify_config config_id="254cd3ef-bbe1-4d58-859d-21b8d0c046c6">
#    <preference>
#      <nvt oid="1.3.6.1.4.1.25623.1.0.14259"/>
#      <name>Nmap (NASL wrapper)[checkbox]:UDP port scan</name>
#      <value>eWVz</value>
#    </preference>
#  </modify_config>
# Manager
#  <modify_config_response status="200"
#                          status_text="OK"/>
# 
# 7.48.3 Example: Modify the families that a config selects
# The outer "growing" element sets the config to add any new families that arrive.
# The client requests the Manager to keep a single selected family (Debian Local Security Checks), 
# to select all NVTs in this family, and to automatically add any new NVTs in this family to the config.
# Client
#  <modify_config config_id="254cd3ef-bbe1-4d58-859d-21b8d0c046c6">
#    <family_selection>
#      <growing>1</growing>
#      <family>
#        <name>Debian Local Security Checks</name>
#        <all>1</all>
#        <growing>1</growing>
#      </family>
#    </family_selection>
#  </modify_config>
# Manager
#  <modify_config_response status="200"
#                          status_text="OK"/>
# 
# 7.48.3 Example: Modify the NVTs that a config selects in a particular family
# Client
#  <modify_config config_id="254cd3ef-bbe1-4d58-859d-21b8d0c046c6">
#    <nvt_selection>
#      <family>Debian Local Security Checks</family>
#      <nvt oid="1.3.6.1.4.1.25623.1.0.53797"/>
#      <nvt oid="1.3.6.1.4.1.25623.1.0.63272"/>
#      <nvt oid="1.3.6.1.4.1.25623.1.0.55615"/>
#      <nvt oid="1.3.6.1.4.1.25623.1.0.53546"/>
#    </nvt_selection>
#  </modify_config>
# Manager
#  <modify_config_response status="200"
#                          status_text="OK"/>
