require 'base64'

class Report

  include OpenvasModel

  attr_accessor :task_id, :task_name, :started_at, :ended_at, :status

  def self.find_by_id_and_format(id, format_name, format_id, user)
    options = {}
    # params = {}
    params =  { :notes=>'1', :notes_details=>'1', 
                :overrides=>'1', :overrides_details=>'1', :apply_overrides=>'1',
                :result_hosts_only=>'1'
              }
    params[:levels] = 'hmlgdf' unless options[:levels]
    params[:report_id] = id if id
    params[:format_id] = format_id if format_id
    req = Nokogiri::XML::Builder.new { |xml| xml.get_reports(params) }
    rep = user.openvas_connection.sendrecv(req.doc)
    if format_name == 'xml'
      r = rep.xpath('//get_reports_response/report').to_xml
    else
      r = Base64.decode64(rep.xpath('//get_reports_response/report').text)
    end
    r
  end

  # pulls report details based off of the options passed.  By default, pulls all reports.
  # options:
  # [:report_id => [report_id]] Pulls a specific +report_id+.  If the id provided is bogus, an empty set is returned.
  # [:levels => [array_of_filter_symbols]] Filters the report results by severity.  Valid symbols are: [:high, :medium, :low, :log, :debug].
  # [:sort => [sort_field]] Sorts the report by the given field.  Possible values are +:task_name+, +:started_at+. defaults to +:started_at+
  # [:sort_order => [:ascending, :descending]] Order of sort.  Defaults to :descending.
  #
  # from gsad_omp.c: get_report_omp: line 5203:
  # <get_reports
  #  notes=%i notes_details=1
  #  overrides=1 overrides_details=1 apply_overrides=%i
  #  result_hosts_only=%i
  #  report_id=%s
  #  format_id=%s
  #  first_result=%u
  #  max_results=%u
  #  sort_field=%s
  #  sort_order=%s
  #  levels=%s
  #  search_phrase=%s
  #  min_cvss_base=%s/>,
  # strcmp (notes, "0") ? 1 : 0,
  # strcmp (overrides, "0") ? 1 : 0,
  # strcmp (result_hosts_only, "0") ? 1 : 0,
  # report_id,
  # format_id ? format_id : "d5da9f67-8551-4e51-807b-b6a873d70e34",
  # first_result,
  # max_results,
  # sort_field ? sort_field : "type",
  # sort_order ? sort_order : ( (sort_field == NULL || strcmp (sort_field, "type") == 0) ? "descending" : "ascending" ),
  # levels,
  # search_phrase,
  # min_cvss_base
  def self.all(user, options = {})
    params =  { :notes=>'1', :notes_details=>'1', 
                :overrides=>'1', :overrides_details=>'1', :apply_overrides=>'1',
                :result_hosts_only=>'1'
              }
    params[:report_id] = options[:id] if options[:id]
    # options[:levels] = [:high,:medium,:low,:log,:debug,:false_positive]
    options[:levels] = [:high,:medium]
    if options[:levels]
      params[:levels] = ''
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
        when :false_positive
          params[:levels] += 'f'
        end
      }
    end
    Rails.logger.info "\n\n get_reports >>> params=#{params.inspect}\n\n"
    req = Nokogiri::XML::Builder.new { |xml|
      if params.empty?
        xml.get_reports
      else
        xml.get_reports(params)
      end
    }
    # Rails.logger.info "\n\n get_reports >>> req=#{req.to_xml.to_yaml}\n\n"
    begin
      resp = user.openvas_connection.sendrecv(req.doc)
    rescue Exception => e
      raise e unless e.message =~ /Failed to find/i
      return []
    end
    ret = []
    # Rails.logger.info "\n\n get_reports >>> resp=#{resp.to_xml.to_yaml}\n\n"
    resp.xpath('/get_reports_response/report/report').each { |r|
      rep = Report.new
      rep.id          = extract_value_from("@id", r)
      rep.task_id     = extract_value_from("task/@id", r)
      rep.task_name   = extract_value_from("task/name", r)
      rep.task_name   = extract_value_from("task/name", r)
      rep.status      = extract_value_from("scan_run_status", r)
      rep.started_at  = Time.parse(extract_value_from("scan_start", r))
      rep.ended_at    = Time.parse(extract_value_from("scan_end", r))
      rep.result_count_total[:total]  = extract_value_from("result_count/full", r).to_i
      rep.result_count_total[:debug]  = extract_value_from("result_count/debug/full", r).to_i
      rep.result_count_total[:high]   = extract_value_from("result_count/hole/full", r).to_i
      rep.result_count_total[:low]    = extract_value_from("result_count/info/full", r).to_i
      rep.result_count_total[:log]    = extract_value_from("result_count/log/full", r).to_i
      rep.result_count_total[:medium] = extract_value_from("result_count/warning/full", r).to_i
      rep.result_count_total[:false_positive] = extract_value_from("result_count/false_positive/full", r).to_i
      rep.result_count_filtered[:total]   = extract_value_from("result_count/filtered", r).to_i
      rep.result_count_filtered[:debug]   = extract_value_from("result_count/debug/filtered", r).to_i
      rep.result_count_filtered[:high]    = extract_value_from("result_count/hole/filtered", r).to_i
      rep.result_count_filtered[:low]     = extract_value_from("result_count/info/filtered", r).to_i
      rep.result_count_filtered[:log]     = extract_value_from("result_count/log/filtered", r).to_i
      rep.result_count_filtered[:medium]  = extract_value_from("result_count/warning/filtered", r).to_i
      rep.result_count_filtered[:false_positive]  = extract_value_from("result_count/false_positive/filtered", r).to_i
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

  def result_count_total
    unless @result_count_total
      @result_count_total = {:total=>0, :debug=>0, :log=>0, :low=>0, :medium=>0, :high=>0}
    end
    @result_count_total
  end

  def result_count_filtered
    unless @result_count_filtered
      @result_count_filtered = {:total=>0, :debug=>0, :log=>0, :low=>0, :medium=>0, :high=>0}
    end
    @result_count_filtered
  end

end