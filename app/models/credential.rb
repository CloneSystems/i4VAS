require 'base64'

class Credential

  include OpenvasModel

  attr_accessor :name, :login, :comment, :password_type, :password, :in_use

  validates :name,      :presence => true, :length => { :maximum => 80 }
  validates :password,  :presence => true, :length => { :maximum => 40 }
  validates :comment, :length => { :maximum => 400 }
  validates :login,   :length => { :maximum => 80 }

  def scan_targets
    @scan_targets ||= []
  end

  def self.selections(user)
    credentials = []
    cred = Credential.new({:id=>'0', :name=>'--'}) # add blank selection, so users can edit Credential selection
    credentials << cred
    self.all(user).each do |c|
      credentials << c
    end
    credentials
  end

  def self.find_public_key_for_id(id, user)
    params = {}
    params[:lsc_credential_id] = id if id
    params[:format] = 'key'
    req = Nokogiri::XML::Builder.new { |xml| xml.get_lsc_credentials(params) }
    rep = user.openvas_connection.sendrecv(req.doc)
    # r = Base64.decode64(rep.xpath('//get_lsc_credentials_response/lsc_credential/public_key').text)
    r = rep.xpath('//get_lsc_credentials_response/lsc_credential/public_key').text
    r
  end

  def self.all(user, options = {})
    params = {}
    params[:lsc_credential_id] = options[:id] if options[:id]
    req = Nokogiri::XML::Builder.new { |xml| xml.get_lsc_credentials(params) }
    ret = []
    begin
      resp = user.openvas_connection.sendrecv(req.doc)
      # Rails.logger.info "\n\n resp=#{resp.to_xml.to_yaml}\n\n"
      resp.xpath("/get_lsc_credentials_response/lsc_credential").each { |xml|
        crd               = Credential.new
        crd.id            = extract_value_from("@id", xml)
        crd.name          = extract_value_from("name", xml)
        crd.login         = extract_value_from("login", xml)
        crd.password_type = extract_value_from("type", xml)
        # crd.password      = extract_value_from("password", xml) # is not returned!
        crd.comment       = extract_value_from("comment", xml)
        crd.in_use        = extract_value_from("in_use", xml).to_i
        xml.xpath("targets/target").each { |t|
          st      = ScanTarget.new
          st.id   = extract_value_from("@id", t)
          st.name = extract_value_from("name", t)
          crd.scan_targets << st
        }
        ret << crd
      }
    rescue Exception => e
      raise e
    end
    ret
  end

end