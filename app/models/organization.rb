require 'safe_yaml'

# Determines which site is shown based on the request domain
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
    yaml_file = if Rails.env.test?
      File.join(Rails.application.root, 'spec', 'support', 'organizations.yml')
    else
      File.join(Rails.application.root, 'config', 'organizations.yml')
    end
    SafeYAML.load_file yaml_file
  end

  def self.find_information_for_domain(domain)
    org_info = load_domain_information
    found_org = org_info.find {|k,v| v['domain'] == domain}
    if found_org
      org_data = found_org[1]
      org_data['initials'] = found_org[0]
      org_data
    else
      raise "No domain information could be found for #{domain}"
    end
  end
end
