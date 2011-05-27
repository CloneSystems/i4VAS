class ScanTarget

  include BasicModel

  extend Openvas_Helper

  attr_accessor :persisted

  attr_accessor :id, :name, :comment, :hosts, :port_range, :in_use

  validates :name, :presence => true

  def persisted?
    @persisted || false
  end

  def self.find(args)
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
        # host_string                = extract_value_from("hosts", t)
        # all_hosts = host_string.split(/,/)
        # all_hosts.each { |hst| hst.strip! }
        # targ.hosts                 = all_hosts
        # targ.comment               = extract_value_from("comment", t)
        # targ.port_range            = extract_value_from("port_range", t)
        # targ.in_use                = extract_value_from("in_use", t).to_i > 0
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

  def save
    valid? ? true : false
  end

  def update_attributes(attrs={})
    attrs.each { |key, value|
      send("#{key}=".to_sym, value) if public_methods.include?("#{key}=".to_sym)
    }
    save
  end

  def destroy
    delete_record
  end

  def self.get_by_id(id)
    get_all(:id => id).first
  end

  def create_or_update
    true
  end

  def delete_record
    true
  end

end