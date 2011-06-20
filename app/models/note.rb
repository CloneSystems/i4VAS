class Note

  include OpenvasModel

  attr_accessor :nvt_oid, :nvt_name, :hosts, :port, :threat, :note_text, :text_excerpt, :orphan
  attr_accessor :creation_time, :modification_time
  attr_accessor :task_id, :task_name
  attr_accessor :result_id, :result_description
  attr_accessor :report_id

  define_attribute_methods [:nvt_oid, :nvt_name, :hosts, :port, :threat, :note_text, :task_id, :result_id, :report_id]

  validates :note_text, :presence => true, :length => { :maximum => 600 }

  def self.parse_result_node(xml)
    nt = Note.new
    nt.id                 = extract_value_from("@id", xml)
    nt.nvt_oid            = extract_value_from("nvt/@oid", xml)
    nt.nvt_name           = extract_value_from("nvt/name", xml)
    nt.hosts              = extract_value_from("hosts", xml)
    nt.hosts              = 'Any' if nt.hosts.blank?
    nt.port               = extract_value_from("port", xml)
    nt.port               = 'Any' if nt.port.blank?
    nt.threat             = extract_value_from("threat", xml)
    nt.threat             = 'Any' if nt.threat.blank?
    nt.note_text          = extract_value_from("text", xml)
    nt.text_excerpt       = extract_value_from("text/@excerpt", xml)
    nt.orphan             = extract_value_from("orphan", xml)
    nt.task_id            = extract_value_from("task/@id", xml)
    nt.task_name          = extract_value_from("task/name", xml)
    nt.task_name          = 'Any' if nt.task_id.blank?
    nt.result_id          = extract_value_from("result/@id", xml)
    nt.result_description = extract_value_from("result/description", xml)
    nt.result_description = 'Any' if nt.result_id.blank?
    nt.creation_time      = extract_value_from("creation_time", xml)
    nt.modification_time  = extract_value_from("modification_time", xml)
    nt
  end

  class Selection
    attr_accessor :id, :name
    def initialize(attributes = {})
      attributes.each { |name, value| send("#{name}=", value) } unless attributes.nil?
    end
  end

  def self.two_selections(second_id, second_name)
    s = []
    s << Selection.new({:id=>'', :name=>'Any'})
    unless second_id.blank?
      if second_name.blank?
        s << Selection.new({:id=>second_id, :name=>second_id})
      else
        s << Selection.new({:id=>second_id, :name=>second_name})
      end
    end
    s
  end

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
  # 1.
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
  #
  # 2.
  # <get_notes_response status="200" status_text="OK">
  #   <note id="835f7a1e-a313-437c-9636-08bcbea25d16">
  #     <nvt oid="0">
  #       <name>(null)</name>
  #     </nvt>
  #     <creation_time>Fri Jun 17 19:59:57 2011</creation_time>
  #     <modification_time>Fri Jun 17 19:59:57 2011</modification_time>
  #     <text>task: any result: any</text>
  #     <hosts>127.0.0.1</hosts>
  #     <port>https (443/tcp)</port>
  #     <threat>Log</threat>
  #     <task id="">
  #       <name/>
  #     </task>
  #     <orphan>0</orphan>
  #     <result id=""/>
  #   </note>
  # </get_notes_response>

  def self.all(user, options = {})
    params = {:details => "1", :result => "1"}
    params[:note_id] = options[:id] if options[:id]
    req = Nokogiri::XML::Builder.new { |xml| xml.get_notes(params) }
    ret = []
    begin
      resp = user.openvas_connection.sendrecv(req.doc)
      # Rails.logger.info "\n\n Note.all >>> resp=#{resp.to_xml.to_yaml}\n\n"
      resp.xpath("/get_notes_response/note").each { |xml|
        ret << Note.parse_result_node(xml)
      }
    rescue Exception => e
      raise e
    end
    ret
  end

  def save(user)
    if valid?
      n = Note.find(self.id, user) unless self.id.blank? # for update action
      n = Note.new if n.blank? # for create action
      n.note_text = self.note_text
      # n.report_id = self.report_id
      n.task_id = self.task_id
      n.result_id = self.result_id
      n.nvt_oid = self.nvt_oid
      n.hosts = self.hosts
      n.port = self.port
      n.threat = self.threat
      n.create_or_update(user)
      n.errors.each do |attribute, msg|
        self.errors.add(:openvas, "<br />" + msg)
      end
      return false unless self.errors.blank?
      return true
    else
      return false
    end
  end

  def update_attributes(user, attrs={})
    attrs.each { |key, value| send("#{key}=".to_sym, value) if public_methods.include?("#{key}=".to_sym) }
    save(user)
  end

  def create_or_update(user)
    req = Nokogiri::XML::Builder.new { |xml|
      if @id
        xml.modify_note(:note_id => @id) {
          xml.text_     { xml.text(@note_text) }
        }
      else
        xml.create_note {
          xml.text_   { xml.text(@note_text) }
          xml.hosts   { xml.text(@hosts) }
          xml.port    { xml.text(@port) }
          xml.threat  { xml.text(@threat) }
          xml.nvt(:oid => @nvt_oid)
          xml.result(:id => @result_id)
          # xml.report(:id => @report_id)
          xml.task(:id => @task_id)
          # nvt_oid= (hidden)
          # hosts=
          # port=
          # threat=
          # task_id=
          # result_id=
          # text=
        }
      end
    }
    begin
      Rails.logger.info "\n\n req.doc=#{req.doc.to_xml.to_yaml}\n\n"
      resp = user.openvas_connection.sendrecv(req.doc)
      Rails.logger.info "\n\n resp=#{resp.to_xml.to_yaml}\n\n"
      unless Credential.extract_value_from("//@status", resp) =~ /20\d/
        msg = Credential.extract_value_from("//@status_text", resp)
        errors[:command_failure] << msg
        return nil
      end
      true
    rescue Exception => e
      errors[:command_failure] << e.message
      nil
    end
  end

  def delete_record(user)
    req = Nokogiri::XML::Builder.new { |xml| xml.delete_note(:note_id => @id) }
    begin
      user.openvas_connection.sendrecv(req.doc)
      true
    rescue Exception => e
      errors[:command_failure] << e.message
      nil
    end
  end

end