require 'base64'

class Report

  include BasicModel

  extend Openvas_Helper

  attr_accessor :id
  attr_accessor :task_id
  attr_accessor :task_name
  attr_accessor :started_at
  attr_accessor :ended_at
  attr_accessor :status # overall status only


class ReportFormat
  attr_accessor :id, :name
end

  def self.formats(user)
    req = Nokogiri::XML::Builder.new { |xml| xml.get_report_formats }
    formats = user.openvas_connection.sendrecv(req.doc)
    ret = []
    formats.xpath('/get_report_formats_response/report_format').each { |r|
      fmt            = ReportFormat.new
      fmt.id         = extract_value_from("@id", r)
      fmt.name       = extract_value_from("name", r)
      ret << fmt
    }
    ret
  end

  def self.find_by_id_and_format(id, format_id, user)
    params = {}
    params[:report_id] = id if id
    params[:format_id] = format_id if format_id
    req = Nokogiri::XML::Builder.new { |xml| xml.get_reports(params) }
puts "\n\n ***req=#{req.inspect}\n\n****************************************************************************"
    rep = user.openvas_connection.sendrecv(req.doc)
puts "\n\n ***rep=#{rep.inspect}\n\n****************************************************************************"
    r = Base64.decode64 rep.xpath('//get_reports_response/report').text
    r
  end

  def self.find(id, user)
    r = self.all(user, :id => id).first
    r = r.id == id ? r : nil # ensure "first" report has the desired id
  end

  # pulls report details based off of the options passed.  By default, pulls all reports.
  # === Options:
  # [:report_id => [report_id]] Pulls a specific +report_id+.  If the id provided is bogus, an empty set is returned.
  # [:levels => [array_of_filter_symbols]] Filters the report results by severity.  Valid symbols are: [:high, :medium, :low, :log, :deubg].
  # [:sort => [sort_field]] Sorts the report by the given field.  Possible values are +:task_name+, +:started_at+. defaults to +:started_at+
  # [:sort_order => [:ascending, :descending]] Order of sort.  Defaults to :descending.
  def self.all(user, options = {})
    params = {}
    params[:report_id] = options[:id] if options[:id]
    if options[:levels]
      params[:levels] = ""
      options[:levels].each { |f|
        case f
        when :high
          params[:levels] += 'h'
        when :medium
          params[:levels] += 'm'
        when :low
          params[:levels] += 'l'
        when :log
          params[:levels] += 'g'
        when :debug
          params[:levels] += 'd'
        end
      }
    end
    req = Nokogiri::XML::Builder.new { |xml|
      if params.empty?
        xml.get_reports
      else
        xml.get_reports(params)
      end
    }
    begin
      repts = user.openvas_connection.sendrecv(req.doc)
    rescue Exception => e
      raise e unless e.message =~ /Failed to find/i
      return []
    end
    ret = []
    repts.xpath('/get_reports_response/report/report').each { |r|
      rep            = Report.new
      rep.id         = extract_value_from("@id", r)
      rep.task_id    = extract_value_from("task/@id", r)
      rep.task_name  = extract_value_from("task/name", r)
      rep.status     = extract_value_from("scan_run_status", r)
      rep.started_at = Time.parse(extract_value_from("scan_start", r))
      rep.ended_at = Time.parse(extract_value_from("scan_end", r))
      rep.result_count[:total]             = extract_value_from("result_count/full", r).to_i
      rep.result_count[:filtered]          = extract_value_from("result_count/filtered", r).to_i
      rep.result_count[:debug][:total]     = extract_value_from("result_count/debug/full", r).to_i
      rep.result_count[:debug][:filtered]  = extract_value_from("result_count/debug/filtered", r).to_i
      rep.result_count[:high][:total]      = extract_value_from("result_count/hole/full", r).to_i
      rep.result_count[:high][:filtered]   = extract_value_from("result_count/hole/filtered", r).to_i
      rep.result_count[:low][:total]       = extract_value_from("result_count/info/full", r).to_i
      rep.result_count[:low][:filtered]    = extract_value_from("result_count/info/filtered", r).to_i
      rep.result_count[:log][:total]       = extract_value_from("result_count/log/full", r).to_i
      rep.result_count[:log][:filtered]    = extract_value_from("result_count/log/filtered", r).to_i
      rep.result_count[:medium][:total]    = extract_value_from("result_count/warning/full", r).to_i
      rep.result_count[:medium][:filtered] = extract_value_from("result_count/warning/filtered", r).to_i
      # r.xpath("./results/result").each { |result|
      #   rep.results << VasResult.parse_result_node(result)
      # }
      ret << rep
    }
    options[:sort] = :started_at unless options[:sort]
    options[:sort_order] = :descending unless options[:sort_order]
    unless options[:id]
      if options[:sort] == :started_at
        if options[:sort_order] == :ascending
          ret.sort! { |a,b| a.started_at <=> b.started_at }
        else
          ret.sort! { |a,b| b.started_at <=> a.started_at }
        end
      elsif options[:sort] == :task_name
        if options[:sort_order] == :ascending
          ret.sort! { |a,b| a.task_name <=> b.task_name }
        else
          ret.sort! { |a,b| b.task_name <=> a.task_name }
        end
      end
    end
    ret
  end

  def result_count
    unless @result_count
      @result_count = {:total  => 0, :filtered => 0, 
                       :debug  => {:total => 0, :filtered => 0},
                       :log    => {:total => 0, :filtered => 0},
                       :low    => {:total => 0, :filtered => 0},
                       :medium => {:total => 0, :filtered => 0},
                       :high   => {:total => 0, :filtered => 0}
                       }
    end
    @result_count
  end

end