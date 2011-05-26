module Openvas_Helper

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

end