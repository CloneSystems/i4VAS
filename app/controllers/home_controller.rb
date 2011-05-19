class HomeController < ApplicationController

  include Cls

  def index
puts "\n\nspud=#{Cls.spud.inspect}\n\n"
    # vas = Service.new

    # OpenvasCli.configure { |config|
    #   config.host = "192.168.1.4"
    #   config.username = "admin"
    #   config.password = "spectre"
    #   # config.host = "199.187.124.38"
    #   # config.username = "testuser"
    #   # config.password = "1q2w3e4r"
    # }

    # cfgs = OpenvasCli::VasConfig.get_all(:show_details => true)
    cfgs = OpenvasCli::VasConfig.get_all
logger.info "\n\n cfgs=#{cfgs.count}\n"
cfgs.each do |c|
  logger.info "config=#{c.id} | #{c.name} | tasks=#{c.tasks.count}\n" if c.families_grow
end

    targets = OpenvasCli::VasTarget.get_all
logger.info "\n\n targets=#{targets.count}\n"
targets.each do |t|
  logger.info "target=#{t.id} | #{t.name} | tasks=#{t.tasks.count}\n"
end
logger.info "\n\n"

    # families = OpenvasCli::VasNVTFamily.get_all
    # nvts = OpenvasCli::VasNVT.get_all(:family => families.choice.name)
    # nvts.each { |n|
    #   puts "risk_factor => #{n.risk_factor}"
    # }

    @tasks = OpenvasCli::VasTask.get_all
end

  end

end