class Schedule

  include BasicModel

  extend Openvas_Helper

  attr_accessor :persisted

  attr_accessor :id, :name, :comment, :first_time, :period_amount, :period_unit, :duration_amount, :duration_unit, :next_time
  attr_accessor :next_time, :in_use, :task_ids
  # attr_reader   :period
  # attr_accessor :duration

  validates :name, :presence => true, :length => { :maximum => 80 }
  validates :comment, :length => { :maximum => 400 }
  validates :first_time, :presence => true, :length => { :maximum => 80 }

  def persisted?
    @persisted || false
  end

  def new_record?
    @id == nil || @id.empty?
  end

  def self.selections(user)
    targets = []
    targets = self.all(user)
  end

  def self.all(user, options = {})
    manual_sort = false
    params = {:details => '1'}
    params[:schedule_id] = options[:id] if options[:id]
    case options[:sort_by]
      when :schedule_id
        params[:sort_field] = 'id'
      when :next_time
        manual_sort = true
      when :first_time
        params[:sort_field] = 'first_time'
      else
        params[:sort_field] = 'name'
    end
    req = Nokogiri::XML::Builder.new { |xml| xml.get_schedules(params) }
    ret = []
    begin
      schedules = user.openvas_connection.sendrecv(req.doc)
      schedules.xpath("//schedule").each { |s|
        sch               = Schedule.new
        sch.id            = extract_value_from("@id", s)
        sch.name          = extract_value_from("name", s)
        sch.comment       = extract_value_from("comment", s)
        t_time            = extract_value_from("first_time", s)
        sch.first_time    = Time.parse(t_time) unless t_time == ""
        t_time            = extract_value_from("next_time", s)
puts "\n\n t_time=#{t_time.inspect}\n\n"
        sch.next_time     = Time.parse(t_time) unless t_time == "" or t_time == "done" or t_time == "over"
        # period_num = extract_value_from("period", s).to_i
        # if period_num > 0
        #   sch.period = VasPeriod.from_seconds(period_num)
        # end
        # period_num = extract_value_from("period_months", s).to_i
        # if period_num > 0
        #   sch.period = VasPeriod.from_months(period_num)
        # end
        # t_time            = extract_value_from("duration", s)
        # unless t_time == ""
        #   sch.duration = t_time.to_i unless t_time == 0
        # end
        sch.in_use        = extract_value_from("in_use", s).to_i > 0
        sch.task_ids = []
        # s.xpath('tasks/task/@id') { |t|
        #   sch.task_ids << t.value
        # }
        ret << sch
      }
      if manual_sort
        if options[:sort_by] == :next_time
          ret.sort!{ |a,b| a.next_time <=> b.next_time }
        end
      end
    rescue Exception => e
      raise e
    end
    ret
  end

  def self.find(id, user)
    return nil if id.blank? || user.blank?
    f = self.all(user, :id => id).first
    return nil if f.blank?
    # ensure "first" has the desired id:
    if f.id.to_s == id.to_s
      return f
    else
      return nil
    end
  end

  def save(user)
    # note modify(edit/update) is not implemented in OMP 2.0
    if valid?
      st = ScanTarget.new
      st.name         = self.name
      st.comment      = self.comment
      st.hosts_string = self.hosts
      st.port_range   = self.port_range
      st.create_or_update(user)
      st.errors.each do |attribute, msg|
        self.errors.add(:openvas, "<br />" + msg)
      end
      return false unless self.errors.blank?
      return true
    else
      return false
    end
  end

  def update_attributes(attrs={})
    # note modify(edit/update) is not implemented in OMP 2.0
    # attrs.each { |key, value|
    #   send("#{key}=".to_sym, value) if public_methods.include?("#{key}=".to_sym)
    # }
    # save
  end

  def destroy
    delete_record
  end

end