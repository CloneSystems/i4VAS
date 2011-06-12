class Override

  include OpenvasModel

  attr_accessor :nvt_oid, :nvt_name, :hosts, :port, :threat, :override_text, :text_excerpt, :orphan

  define_attribute_methods [:nvt_oid, :nvt_name, :hosts, :port, :threat, :override_text, :text_excerpt, :orphan]

  validates :override_text, :length => { :maximum => 600 }

  def self.all(user, options = {})
    params = {:details => "1", :result => "1"}
    params[:override_id] = options[:id] if options[:id]
    req = Nokogiri::XML::Builder.new { |xml| xml.get_overrides(params) }
    ret = []
    begin
      resp = user.openvas_connection.sendrecv(req.doc)
      # Rails.logger.info "\n\n resp=#{resp.to_xml.to_yaml}\n\n"
      resp.xpath("/get_overrides_response/override").each { |xml|
        ovr = Override.new
        ovr.id            = extract_value_from("@id", xml)
        ovr.nvt_oid       = extract_value_from("nvt/@oid", xml)
        ovr.nvt_name      = extract_value_from("nvt/name", xml)
        ovr.override_text = extract_value_from("text", xml)
        ovr.text_excerpt  = extract_value_from("text/@excerpt", xml)
        ovr.orphan        = extract_value_from("orphan", xml)
        ret << ovr
      }
    rescue Exception => e
      raise e
    end
    ret
  end

end