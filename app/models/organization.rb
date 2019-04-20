require 'safe_yaml'

# Represents a group that owns listings - e.g. a county, a city,
# or a housing developer
class Organization
  def self.lookup_initials=(value)
    Thread.current['lookup_initials'] = value
  end

  def self.lookup_initials
    Thread.current['lookup_initials']
  end

  # rubocop:disable Style/RedundantSelf
  def self.t(lookup_name, *args)
    I18n.t("#{self.lookup_initials}.#{lookup_name}", *args)
  end
  # rubocop:enable Style/RedundantSelf

  def self.load_domain_information
    SafeYAML.load_file yaml_filepath
  end

  def self.yaml_filepath
    if Rails.env.test?
      File.join(Rails.application.root, 'spec', 'support', 'organizations.yml')
    else
      File.join(Rails.application.root, 'config', 'organizations.yml')
    end
  end

  def self.find_information_for_domain(domain)
    org_info = load_domain_information
    found_org = org_info.find { |_k, v| domain.include? v['domain'] }

    raise 'No domain information could be found' unless found_org

    org_data = found_org[1]
    org_data['initials'] = found_org[0]
    org_data
  end
end
