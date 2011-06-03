class ScanConfig

  include OpenvasModel

  attr_accessor :name, :comment, :family_count, :families_grow, :nvt_count, :nvts_grow, :in_use

  validates :name, :presence => true, :length => { :maximum => 80 }
  validates :comment, :length => { :maximum => 400 }

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
        # next if extract_value_from("name", xml) == 'empty'
        cfg               = ScanConfig.new
        cfg.id            = extract_value_from("@id", xml)
        cfg.name          = extract_value_from("name", xml)
        cfg.comment       = extract_value_from("comment", xml)
        cfg.family_count  = extract_value_from("family_count", xml).to_i
        cfg.families_grow = extract_value_from("family_count/growing", xml).to_i
        cfg.nvt_count     = extract_value_from("nvt_count", xml).to_i
        cfg.nvts_grow     = extract_value_from("nvt_count/growing", xml).to_i
        cfg.in_use        = extract_value_from("in_use", xml).to_i
        # xml.xpath("tasks/task").each { |t| cfg.tasks << VasTask.from_xml_node(t) }
        # xml.xpath("families/family").each { |f| cfg.families << VasNVTFamily.from_xml_node(f) }
        # xml.xpath("preferences/preference").each { |p| 
        #   p = VasPreference.from_xml_node(p) 
        #   p.config_id = cfg.id
        #   cfg.preferences << p
        # }
        ret << cfg
      }
    rescue Exception => e
      raise e
    end
    ret
  end

  def update_attributes(user, attrs={})
    attrs.each { |key, value|
      send("#{key}=".to_sym, value) if public_methods.include?("#{key}=".to_sym)
    }
    save(user)
  end

end