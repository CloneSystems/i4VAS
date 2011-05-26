require 'socket' 
require 'timeout'
require 'openssl'
require 'nokogiri'

module OpenVas

	class OMPError < :: RuntimeError
		attr_accessor :req, :reason
		def initialize(req, reason = '')
			self.req = req
			self.reason = reason
		end
		def to_s
			"OpenVAS OMP: #{self.reason}"
		end
	end

	class OMPResponseError < OMPError
		def initialize
			self.reason = "Error in OMP request/response"
		end
	end

	class OMPAuthError < OMPError
		def initialize
			self.reason = "Authentication failed"
		end
	end

	class XMLParsingError < OMPError
		def initialize
			self.reason = "XML parsing failed"
		end
	end

  class Connection
  	# Usage:
  	#  ov=VasConnection.new(host=>'localhost', port=>'9390', user=>'user', password=>'pass')
  	def initialize(p={})
  		if p.has_key?("host")
  			@host = p["host"]
  		else
  			@host = "localhost"
  		end
  		if p.has_key?("port")
  			@port = p["port"]
  		else
  			@port = 9390
  		end
  		if p.has_key?("user")
  			@user = p["user"]
  		else
  			@user = "openvas"
  		end
  		if p.has_key?("password")
  			@password = p["password"]
  		else
  			@password = "openvas"
  		end
  		if p.has_key?("bufsize")
  			@bufsize = p["bufsize"]
  		else
  			@bufsize = 16384
  		end
  		@areq=''
  		@read_timeout = 30 # seconds
      connect()
      login()
  	end

  	# Low level method - Connect to SSL socket
  	# Usage:
  	# ov.connect()
  	def connect
  		@plain_socket=TCPSocket.open(@host, @port)
  		ssl_context = OpenSSL::SSL::SSLContext.new()
  		@socket = OpenSSL::SSL::SSLSocket.new(@plain_socket, ssl_context)
  		@socket.sync_close = true
  		@socket.connect
  	end

  	# Low level method - Disconnect SSL socket
  	# Usage:
  	# ov.disconnect()
  	def disconnect
  		if @socket
  			@socket.close
  		end
  	end

  	# Low level method: Send request and receive response - socket
  	# Usage:
  	# ov.connect();
  	# puts ov.sendrecv("<get_version/>")
  	# ov.disconnect();
  	def sendrecv(tosend)
  		if not @socket
  			connect
  		end
  		@socket.puts(tosend)
  		@rbuf = ''
  		size = 0
  		begin	
  			begin
  				timeout(@read_timeout) {
    		    a = @socket.sysread(@bufsize)
    		    size = a.length
    		    @rbuf << a
  				}
  			rescue Timeout::Error
  				size = 0
  			rescue EOFError
  				raise OMPResponseError
  			end
  		end while size >= @bufsize
  		response = @rbuf
  		return Nokogiri::XML(response)
  	end

    # Helper method to extract a value from a Nokogiri::XML::Node object.  If the
    # xpath provided contains an @, then the method assumes that the value resides
    # in an attribute, otherwise it pulls the text of the last +text+ node.
    def extract_value_from(x_str, n)
      ret = ""
      return ret if x_str.nil? || x_str.empty?
      if x_str =~ /@/
        ret = n.at_xpath(x_str).value  if n.at_xpath(x_str)
      else
        tn =  n.at_xpath(x_str)
        if tn
          if tn.children.count > 0
            tn.children.each { |tnc|
              if tnc.text?
                ret = tnc.text
              end
            }
          else
            ret = tn.text
          end
        end
      end
      ret
    end

  	# login to OpenVAS server. 
  	# if successful returns authentication XML for further usage
  	# if unsuccessful returns empty string
  	# Usage:
  	# ov.login()
  	def login 
      areq = Nokogiri::XML::Builder.new { |xml|
        xml.authenticate {
          xml.credentials {
            xml.username { xml.text(@user) }
            xml.password { xml.text(@password) }
          }
        }
      }
      resp = sendrecv(areq.doc)
      begin
        if extract_value_from("//@status", resp) =~ /20\d/
          @areq = areq
        elsif extract_value_from("//@status", resp) =~ /40\d/
          disconnect()
          return false
        else
          puts "\n\n***OMPAuthError*** OpenVAS response=#{resp.inspect}\n\n"
          raise OMPAuthError
        end
      rescue
        puts "\n\n***XMLParsingError*** OpenVAS response=#{resp.inspect}\n\n"
        raise XMLParsingError
      end
  	end

  	# check if we're successful logged in
  	# if successful returns true
  	# if unsuccessful returns false
  	# Usage:
  	# if ov.logged_in? then
  	# 	puts "logged in?"
  	# end
  	def logged_in?
  		if @areq == '' || @areq.nil?
  			return false
  		else
  			return true
  		end
  	end

  	# logout from OpenVAS server. 
  	# it actually just sets internal authentication XML to empty str
  	# (as in OMP you have to send username/password each time)
  	# (i.e. there is no session id)
  	# Usage:
  	# ov.logout()
  	def logout
  		disconnect()
  		@areq = ''
  	end

  end
end