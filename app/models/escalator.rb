class Escalator

  include OpenvasModel

  attr_accessor :name, :comment, :in_use
  attr_accessor :escalator_event,     :event_data,      :event_data_name
  attr_accessor :escalator_condition, :condition_data,  :condition_data_name
  attr_accessor :escalator_method,    :method_data,     :method_data_name
  attr_accessor :email_to_address, :email_from_address, :email_report_format, :http_get_url
  attr_accessor :method_datas, :condition_datas

  validates :name, :presence => true, :length => { :maximum => 80 }
  validates :comment, :length => { :maximum => 400 }

  class Datum
    attr_accessor :data, :name
  end

  class Selection
    attr_accessor :id, :name

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end unless attributes.nil?
    end
  end

  def self.event_selections
    events = []
    events << Selection.new({:id=>'Done', :name=>'Done'})
    events << Selection.new({:id=>'Delete Requested', :name=>'Delete Requested'})
    events << Selection.new({:id=>'New', :name=>'New'})
    events << Selection.new({:id=>'Requested', :name=>'Requested'})
    events << Selection.new({:id=>'Running', :name=>'Running'})
    events << Selection.new({:id=>'Stop Requested', :name=>'Stop Requested'})
    events << Selection.new({:id=>'Stopped', :name=>'Stopped'})
    events
  end

  def self.condition_selections
    conditions = []
    conditions << Selection.new({:id=>'always',     :name=>'Always'})
    conditions << Selection.new({:id=>'high',       :name=>'Threat level at least High'})
    conditions << Selection.new({:id=>'medium',     :name=>'Threat level at least Medium'})
    conditions << Selection.new({:id=>'low',        :name=>'Threat level at least Low'})
    conditions << Selection.new({:id=>'log',        :name=>'Threat level at least Log'})
    conditions << Selection.new({:id=>'changed',    :name=>'Threat level changed'})
    conditions << Selection.new({:id=>'increased',  :name=>'Threat level increased'})
    conditions << Selection.new({:id=>'decreased',  :name=>'Threat level decreased'})
    conditions
  end

  def self.method_selections
    methods = []
    methods << Selection.new({:id=>'Email', :name=>'Email'})
    methods << Selection.new({:id=>'syslog syslog', :name=>'System Logger (Syslog)'})
    methods << Selection.new({:id=>'syslog SNMP', :name=>'SNMP'})
    methods << Selection.new({:id=>'HTTP Get', :name=>'HTTP Get'})
    methods
  end

  def self.selections(user)
    escalators = []
    esc = Escalator.new({:id=>'0', :name=>'--'}) # add blank selection, so users can edit Escalator selection
    escalators << esc
    self.all(user).each do |e|
      escalators << e
    end
    escalators
  end

  def self.all(user, options = {})
    params = {}
    params[:config_id] = options[:id] if options[:id]
    req = Nokogiri::XML::Builder.new { |xml| xml.get_escalators(params) }
    ret = []
    begin
      resp = user.openvas_connection.sendrecv(req.doc)
Rails.logger.info "\n\n resp=#{resp.to_xml.to_yaml}\n\n"
      resp.xpath("/get_escalators_response/escalator").each { |xml|
        esc = Escalator.new
        esc.id                  = extract_value_from("@id", xml)
        esc.name                = extract_value_from("name", xml)
        esc.comment             = extract_value_from("comment", xml)
        esc.in_use              = extract_value_from("in_use", xml).to_i
        esc.escalator_event     = extract_value_from("event", xml)
        esc.event_data          = extract_value_from("event/data", xml)
        esc.event_data_name     = extract_value_from("event/data/name", xml)
        esc.escalator_condition = extract_value_from("condition", xml)
        # esc.condition_data      = extract_value_from("condition/data", xml)
        # esc.condition_data_name = extract_value_from("condition/data/name", xml)
        esc.condition_datas = []
        xml.search("condition > data").each do |data|
          dt = Datum.new
          # remove the <name> element from the <data> element, so we can get the <data> text:
          name = data.search("name").remove
          dt.data = data.text
          dt.name = name.text
          esc.condition_datas << dt unless dt.name.blank?
        end
        esc.escalator_method    = extract_value_from("method", xml)
        esc.method_datas = []
        # note: this also works --> xml.search("method/data").each do |data|
        xml.search("method > data").each do |data|
          dt = Datum.new
          # remove the <name> element from the <data> element, so we can get the <data> text:
          name = data.search("name").remove
          dt.data = data.text
          dt.name = name.text
          if dt.name == 'notice' && dt.data == '1'
            dt.name = 'Content'
            dt.data = 'Simple Notice'
          elsif dt.name == 'to_address'
            dt.name = 'To'
          elsif dt.name == 'notice_report_format'
            dt.name = 'Content'
            dt.data = 'Include report ' + ReportFormat.find(dt.data, user).name
          end
          esc.method_datas << dt unless dt.name.blank?
        end
        ret << esc
      }
    rescue Exception => e
      raise e
    end
    ret
  end

  def save(user)
    # note modify(edit/update) is not implemented in OMP 2.0
    if valid?
      esc = Escalator.new
      esc.name                = self.name
      esc.comment             = self.comment
      esc.escalator_event     = self.escalator_event
      esc.escalator_condition = self.escalator_condition
      esc.escalator_method    = self.escalator_method
      esc.email_to_address    = self.email_to_address
      esc.email_from_address  = self.email_from_address
      esc.email_report_format = self.email_report_format
      esc.http_get_url        = self.http_get_url
      esc.create_or_update(user)
      esc.errors.each do |attribute, msg|
        self.errors.add(:openvas, "<br />" + msg)
      end
      return false unless self.errors.blank?
      return true
    else
      return false
    end
  end

  def create_or_update(user)
    # note modify(edit/update) is not implemented in OMP 2.0
    req = Nokogiri::XML::Builder.new { |xml|
      xml.create_escalator {
        xml.name    { xml.text(@name) }
        xml.comment { xml.text(@comment) } unless @comment.blank?
        # method xml:
        if @escalator_method =~ /syslog /
          mdata = @escalator_method.split(' ')
          # note: using xml.method does not work (who picked a common word?), anyway, appending a hyphen (xml.method_) is a work around:
          xml.method_ {
            xml.text(mdata[0])
            xml.data {
              xml.text(mdata[1])
              xml.name { xml.text('submodule') }
            }
          }
        elsif @escalator_method == 'HTTP Get'
          if @http_get_url.blank?
            errors['HTTP Get'] << 'URL is required when HTTP Get is selected'
            return nil
          end
          xml.method_ {
            xml.text(@escalator_method)
            xml.data {
              xml.text(@http_get_url)
              xml.name { xml.text('URL') }
            }
          }
        elsif @escalator_method == 'Email'
          # attr_accessor :email_to_address, :email_from_address, :email_report_format, :http_get_url
          if @email_to_address.blank?
            errors['Email'] << 'To Address is required when Email is selected'
          end
          if @email_from_address.blank?
            errors['Email'] << 'From Address is required when Email is selected'
          end
          return nil if errors.count > 0
          xml.method_ {
            xml.text(@escalator_method)
            xml.data {
              xml.text(@email_to_address)
              xml.name { xml.text('to_address') }
            }
            xml.data {
              xml.text(@email_from_address)
              xml.name { xml.text('from_address') }
            }
            if @email_report_format.downcase == 'simple'
              xml.data {
                xml.text('1')
                xml.name { xml.text('notice') }
              }
            else
              # not a simple notice:
              xml.data {
                xml.text('0')
                xml.name { xml.text('notice') }
              }
              xml.data {
                xml.text(@email_report_format)
                xml.name { xml.text('notice_report_format') }
              }
            end
          }
        else
          xml.method_ { xml.text(@escalator_method) }
        end

        # note: the following C code is how GSA handles the create_escalator command:
        # *** from gsad_omp.c ... create_escalator_omp (line 2631):
        # /* special case the syslog submethods, because HTTP only allows one value to vary per radio. */
        # if (strncmp (method, "syslog ", strlen ("syslog ")) == 0) {
        #     gchar *data;
        #     data = g_strdup_printf ("submethod0%s", method + strlen ("syslog "));
        #     data[strlen ("submethod")] = '\0';
        #     if (method_data == NULL)
        #       method_data = g_array_new (TRUE, FALSE, sizeof (gchar*));
        #     g_array_append_val (method_data, data);
        #     method = "syslog";
        # }
        # if (openvas_server_sendf (&session, "<create_escalator>" "<name>%s</name>" "%s%s%s", name,
        #                           comment ? "<comment>" : "",
        #                           comment ? comment : "",
        #                           comment ? "</comment>" : "")
        #     || openvas_server_sendf (&session, "<event>%s", event)
        #     || send_escalator_data (&session, event_data)
        #     || openvas_server_send (&session, "</event>")
        #     || openvas_server_sendf (&session, "<method>%s", method)
        #     || send_escalator_data (&session, method_data)
        #     || openvas_server_send (&session, "</method>")
        #     || openvas_server_sendf (&session, "<condition>%s", condition)
        #     || send_escalator_data (&session, condition_data)
        #     || openvas_server_send (&session,
        #                             "</condition>"
        #                             "</create_escalator>"))
        #   {
        #     g_string_free (xml, TRUE);
        #     openvas_server_close (socket, session);

        # *** from gsad_omp.c ... send_escalator_data (line 2599):
        # static int
        # send_escalator_data (gnutls_session_t *session, GArray *data) {
        #   int index = 0;
        #   gchar *element;
        #   if (data)
        #     while ((element = g_array_index (data, gchar*, index++)))
        #       if (openvas_server_sendf_xml (session,
        #                                     "<data><name>%s</name>%s</data>",
        #                                     element,
        #                                     element + strlen (element) + 1))
        #         return -1;
        #   return 0;
        # }

        # event xml:
        escalator_text = 'Task run status changed' if ['done', 'delete requested', 'new', 'requested', 'running', 'stop requested', 'stopped'].include? @escalator_event.downcase
        xml.event {
          xml.text(escalator_text)
          xml.data {
            xml.text(@escalator_event)
            xml.name { xml.text('status') }
          }
        }
        # condition xml:
        if @escalator_condition.downcase == 'always'
          xml.condition { xml.text(@escalator_condition) }
        else
          if ['high', 'medium', 'low', 'log'].include? @escalator_condition.downcase
            escalator_text = 'Threat level at least'
            escalator_name = 'level'
          end
          if ['changed', 'increased', 'decreased'].include? @escalator_condition.downcase
            escalator_text = 'Threat level changed'
            escalator_name = 'direction'
          end
          xml.condition {
            xml.text(escalator_text)
            xml.data {
              xml.text(@escalator_condition)
              xml.name { xml.text(escalator_name) }
            }
          }
        end
      }
    }
    begin
      resp = user.openvas_connection.sendrecv(req.doc)
      unless Escalator.extract_value_from("//@status", resp) =~ /20\d/
        msg = Escalator.extract_value_from("//@status_text", resp)
        errors[:command_failure] << msg
        return nil
      end
      @id = Escalator.extract_value_from("/create_escalator_response/@id", resp)
      true
    rescue Exception => e
      errors[:command_failure] << e.message
      nil
    end
  end

  def delete_record(user)
    req = Nokogiri::XML::Builder.new { |xml| xml.delete_escalator(:escalator_id => @id) }
    begin
      resp = user.openvas_connection.sendrecv(req.doc)
      true
    rescue Exception => e
      errors[:command_failure] << e.message
      nil
    end
  end

end