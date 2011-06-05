class Escalator

  include OpenvasModel

  attr_accessor :name, :comment, :in_use
  attr_accessor :escalator_event,     :event_data,      :event_data_name
  attr_accessor :escalator_condition, :condition_data,  :condition_data_name
  attr_accessor :escalator_method,    :method_data,     :method_data_name

  validates :name, :presence => true, :length => { :maximum => 80 }
  validates :comment, :length => { :maximum => 400 }

  def method_datas
    @method_datas ||= []
  end

  class Datum
    attr_accessor :data, :name
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
        esc.condition_data      = extract_value_from("condition/data", xml)
        esc.condition_data_name = extract_value_from("condition/data/name", xml)
        esc.escalator_method    = extract_value_from("method", xml)
        # note: this also works --> resp.search("method/data").each do |data|
        resp.search("method > data").each do |data|
          dt = Datum.new
          # remove the <name> element from the <data> element:
          name = data.search("name").remove
          dt.data = data.text
          dt.name = name.text
          esc.method_datas << dt
        end
        ret << esc
      }
    rescue Exception => e
      raise e
    end
    ret
  end

  def create_or_update(user)
    # note modify(edit/update) is not implemented in OMP 2.0
    # req = Nokogiri::XML::Builder.new { |xml|
    #   xml.create_schedule {
    #     xml.name    { xml.text(@name) }
    #     xml.comment { xml.text(@comment) } unless @comment.blank?
    #     xml.first_time {
    #       xml.minute       { xml.text(@first_time.min) }
    #       xml.hour         { xml.text(@first_time.hour) }
    #       xml.day_of_month { xml.text(@first_time.day) }
    #       xml.month        { xml.text(@first_time.month) }
    #       xml.year         { xml.text(@first_time.year) }
    #     }
    #     xml.duration {
    #       xml.text(@duration_amount ? @duration_amount : 0)
    #       xml.unit { xml.text(@duration_unit.to_s) }
    #     }
    #     xml.period {
    #       if @period_amount.blank?
    #         xml.text(0)
    #         xml.unit { xml.text("hour") }
    #       else
    #         xml.text(@period_amount ? @period_amount : 0)
    #         xml.unit { xml.text(@period_unit.to_s) }
    #       end
    #     }
    #   }
    # }
    # begin
    #   resp = user.openvas_connection.sendrecv(req.doc)
    #   unless Schedule.extract_value_from("//@status", resp) =~ /20\d/
    #     msg = Schedule.extract_value_from("//@status_text", resp)
    #     errors[:command_failure] << msg
    #     return nil
    #   end
    #   @id = Schedule.extract_value_from("/create_schedule_response/@id", resp)
    #   true
    # rescue Exception => e
    #   errors[:command_failure] << e.message
    #   nil
    # end
  end

end