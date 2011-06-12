class Note

  include OpenvasModel

  attr_accessor :nvt_oid, :nvt_name, :hosts, :port, :threat, :note_text, :text_excerpt, :orphan

  define_attribute_methods [:nvt_oid, :nvt_name, :hosts, :port, :threat, :note_text, :text_excerpt, :orphan]

  validates :note_text, :length => { :maximum => 600 }

  def self.debug_response(user, options = {})
    params = {:details => "1"}
    params[:note_id] = options[:id] if options[:id]
    req = Nokogiri::XML::Builder.new { |xml| xml.get_overrides(params) }
    begin
      resp = user.openvas_connection.sendrecv(req.doc)
      # Rails.logger.info "\n\n resp=#{resp.to_xml.to_yaml}\n\n"
    rescue Exception => e
      raise e
    end
    resp.to_xml.to_yaml
  end

  # xml response for get single Note request:
  # <get_notes_response status="200" status_text="OK">
  #   <note id="49e37821-bcca-45b6-ab97-bb8e9a8c09e7">
  #     <nvt oid="1.3.6.1.4.1.25623.1.0.900239">
  #       <name>Checks for open tcp ports</name>
  #     </nvt>
  #     <creation_time>Sun Jun 12 18:19:48 2011</creation_time>
  #     <modification_time>Sun Jun 12 18:19:48 2011</modification_time>
  #     <text>note for spudder result</text>
  #     <hosts>127.0.0.1</hosts>
  #     <port>general/tcp</port>
  #     <threat>Low</threat>
  #     <task id="5e67b1e9-2a72-4b6c-b62b-7af71aefeea4">
  #       <name>spudder</name>
  #     </task>
  #     <orphan>0</orphan>
  #     <result id="5cd7e3b9-d6f3-4947-8d15-542a0112715e">
  #       <subnet>127.0.0.1</subnet>
  #       <host>127.0.0.1</host>
  #       <port>general/tcp</port>
  #       <nvt oid="1.3.6.1.4.1.25623.1.0.900239">
  #         <name>Checks for open tcp ports</name>
  #         <cvss_base/>
  #         <risk_factor>None</risk_factor>
  #         <cve>NOCVE</cve>
  #         <bid>NOBID</bid>
  #       </nvt>
  #       <threat>Low</threat>
  #       <description>Open TCP ports are 443, 9390, 631</description>
  #     </result>
  #   </note>
  # </get_notes_response>

  def self.all(user, options = {})
    params = {:details => "1", :result => "1"}
    params[:note_id] = options[:id] if options[:id]
    req = Nokogiri::XML::Builder.new { |xml| xml.get_notes(params) }
    ret = []
    begin
      resp = user.openvas_connection.sendrecv(req.doc)
      # Rails.logger.info "\n\n resp=#{resp.to_xml.to_yaml}\n\n"
      resp.xpath("/get_notes_response/note").each { |xml|
        nt = Note.new
        nt.id           = extract_value_from("@id", xml)
        nt.nvt_oid      = extract_value_from("nvt/@oid", xml)
        nt.nvt_name     = extract_value_from("nvt/name", xml)
        nt.note_text    = extract_value_from("text", xml)
        nt.text_excerpt = extract_value_from("text/@excerpt", xml)
        nt.orphan       = extract_value_from("orphan", xml)
        ret << nt
      }
    rescue Exception => e
      raise e
    end
    ret
  end

end