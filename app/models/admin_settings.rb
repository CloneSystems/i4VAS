class AdminSettings

  include OpenvasModel

  attr_accessor :name, :value

  def self.scanner_settings(connection)
    req = Nokogiri::XML::Builder.new { |xml| xml.get_settings }
    resp = connection.sendrecv(req.doc)
    ret = []
    resp.xpath('//scanner_settings/setting').each { |s|
      vs = AdminSettings.new
      vs.name = extract_value_from("@name", s)
      vs.value = s.text
      ret << vs
    }
    ret
  end

end