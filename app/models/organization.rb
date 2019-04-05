require 'safe_yaml'

class Organization
  def self.lookup_initials=(value)
    Thread.current['lookup_initials'] = value
  end

  def self.lookup_initials
    Thread.current['lookup_initials']
  end

  def self.t(lookup_name, *args)
    I18n.t("#{self.lookup_initials}.#{lookup_name}", *args)
  end

  def self.load_domain_information
    SafeYAML.load_file(File.join(Rails.application.root, 'config', 'organizations.yml'))
  end

  def self.find_information_for_domain(domain)
    org_info = load_domain_information
    found_org = org_info.find{|k,v| v['domain'] == domain}
    if found_org
      org_data = found_org[1]
      org_data['initials'] = found_org[0]
      org_data
    else
      raise RuntimeError, "No domain information could be found"
    end
  end
end