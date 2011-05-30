class ScanTarget

  include BasicModel

  extend Openvas_Helper

  attr_accessor :persisted

  attr_accessor :id, :name, :comment, :hosts, :port_range, :in_use, :max_hosts

  validates :name, :presence => true, :length => { :maximum => 80 }
  validates :hosts, :presence => true, :length => { :maximum => 200 }
  validates :port_range, :length => { :maximum => 400 }
  validates :comment, :length => { :maximum => 400 }

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
    params = {:tasks => 1}
    params[:target_id] = options[:id] if options[:id]
    req = Nokogiri::XML::Builder.new { |xml| xml.get_targets(params) }
    ret = []
    begin
      targets = user.openvas_connection.sendrecv(req.doc)
      targets.xpath('//target').each { |t|
        targ                       = ScanTarget.new
        targ.id                    = extract_value_from("@id", t)
        targ.name                  = extract_value_from("name", t)
        targ.max_hosts             = extract_value_from("max_hosts", t)
        host_string                = extract_value_from("hosts", t)
        all_hosts = host_string.split(/,/)
        all_hosts.each { |hst| hst.strip! }
        targ.hosts                 = all_hosts
        targ.comment               = extract_value_from("comment", t)
        targ.port_range            = extract_value_from("port_range", t)
        # targ.in_use                = extract_value_from("in_use", t).to_i > 0
        targ.in_use                = extract_value_from("in_use", t).to_i
        # targ.credential_keys[:ssh] = extract_value_from("ssh_lsc_credential/@id", t)
        # targ.credential_keys[:smb] = extract_value_from("smb_lsc_credential/@id", t)
        # t.xpath('tasks/task').each { |task|
        #   targ.task_keys << extract_value_from("@id", task)
        # }
        # targ.reset_changes
        ret << targ
      }
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

  def hosts_string
    hosts.join(", ")
  end

  def hosts_string=(val)
    self.hosts = val.split(/, ?/)
  end

  def create_or_update(user)
    # note modify(edit/update) is not implemented in OMP 2.0
    req = Nokogiri::XML::Builder.new { |xml|
      xml.create_target {
        xml.name       { xml.text(@name) }
        xml.comment    { xml.text(@comment) } unless @comment.blank?
        xml.hosts      { xml.text(hosts_string) }
        # xml.ssh_lsc_credential(:id => credentials[:ssh].id) if credentials[:ssh]
        # xml.smb_lsc_credential(:id => credentials[:smb].id) if credentials[:smb]
        xml.port_range { xml.text(@port_range) } unless @port_range.blank?
      }
    }
    begin
      resp = user.openvas_connection.sendrecv(req.doc)
      @id = ScanTarget.extract_value_from("/create_target_response/@id", resp)
      true
    rescue Exception => e
      errors[:command_failure] << e.message
      nil
    end
  end

  def delete_record(user)
    req = Nokogiri::XML::Builder.new { |xml| xml.delete_target(:target_id => @id) }
    begin
      user.openvas_connection.sendrecv(req.doc)
      true
    rescue Exception => e
      errors[:command_failure] << e.message
      nil
    end
  end

end