class ScanConfig

  include OpenvasModel

  attr_accessor :name, :comment, :family_count, :families_grow, :nvts_count, :nvts_grow, :in_use
  attr_accessor :tasks

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

  def self.selections(user)
    return nil if user.nil?
    cfgs = []
    self.all(user).each do |o|
      cfgs << o unless o.name == 'empty' # ignore the 'empty'(base) scan config
    end
    cfgs
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
        # xml.xpath("families/family").each { |f| cfg.families << VasNVTFamily.from_xml_node(f) }
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
    attrs.each { |key, value|
      send("#{key}=".to_sym, value) if public_methods.include?("#{key}=".to_sym)
    }
    save(user)
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
