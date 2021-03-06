class ReportFormat

  include OpenvasModel

  attr_accessor :name, :extension, :content_type, :trust, :active, :summary, :description, :parameters

  validates :name, :presence => true, :length => { :maximum => 80 }
  validates :comment, :length => { :maximum => 400 }

  def self.selections(user)
    rfs = []
    rf = ReportFormat.new({:id=>'simple', :name=>'Simple Notice'})
    rfs << rf
    self.all(user).each do |rf|
      rfs << rf
    end
    rfs
  end

  def self.find_id_for_name(user, format_name)
    return '' if format_name.blank?
    req = Nokogiri::XML::Builder.new { |xml| xml.get_report_formats }
    formats = user.openvas_connection.sendrecv(req.doc)
    ret = []
    formats.xpath('/get_report_formats_response/report_format').each { |r|
      fmt            = ReportFormat.new
      fmt.id         = extract_value_from("@id", r)
      fmt.name       = extract_value_from("name", r)
      ret << fmt
    }
    ret.each do |f|
      return f.id if f.name.downcase == format_name
    end
    return ''
  end

  def self.all(user, options = {})
    params = {}
    params[:report_format_id] = options[:id] if options[:id]
    req = Nokogiri::XML::Builder.new { |xml| xml.get_report_formats(params) }
    formats = user.openvas_connection.sendrecv(req.doc)
    ret = []
    begin
      formats.xpath('/get_report_formats_response/report_format').each { |r|
        fmt = ReportFormat.new
        fmt.id            = extract_value_from("@id", r)
        fmt.name          = extract_value_from("name", r)
        fmt.extension     = extract_value_from("extension", r)
        fmt.content_type  = extract_value_from("content_type", r)
        fmt.trust         = extract_value_from("trust", r)
        fmt.active        = extract_value_from("active", r)
        fmt.summary       = extract_value_from("summary", r)
        fmt.description   = extract_value_from("description", r)
        fmt.parameters    = extract_value_from("parameters", r)
        ret << fmt
      }
    rescue Exception => e
      raise e
    end
    ret
  end

  def delete_record(user)
    return if @id.blank?
    req = Nokogiri::XML::Builder.new { |xml| xml.delete_report_format(:report_format_id => @id) }
    begin
      user.openvas_connection.sendrecv(req.doc)
      true
    rescue Exception => e
      errors[:command_failure] << e.message
      nil
    end
  end

end