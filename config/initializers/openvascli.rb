# class OpenvasCli::VasTask
#   def persisted?
#     true
#   end
# end

OpenvasCli.configure { |config|
  config.host = "192.168.1.2"
  config.username = "admin"
  config.password = "spectre"
}
