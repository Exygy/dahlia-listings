# frozen_string_literal: true

def parse_from_json_file(filename)
  json_file_str = File.read "lib/sample_data/#{filename}"
  JSON.parse(json_file_str)
end

def create_listing_from_file(filename, group)
  listing_fields = parse_from_json_file(filename)

  return false if Listing.exists?(listing_id: listing_fields['listing_id'])

  listing = Listing.create(listing_fields)
  listing.group = group
  listing.save
  listing
end

def create_groups
  groups_fields = parse_from_json_file('groups.json')
  groups_fields.each do |fields|
    next if Group.exists?(slug: fields['slug'])
    Group.create(fields)
  end
end

def create_unit(listing)
  unit_fields = parse_from_json_file('unit.json')
  unit = Unit.create(unit_fields)
  unit.listing = listing
  unit.save
end

# Create the placeholder groups and listings that we're using to represent the
# real SMC and SJ groups and listings. Once Phase 1 of regional DAHLIA is
# launched, we will have finalized the actual data for the real SMC and SJ
# groups and listings and will remove the SMC and SJ placeholder data. We
# will keep the test data and add more test data.
create_groups

%w[test smc sj].each do |slug|
  listing = create_listing_from_file(
    "#{slug}_listing.json",
    Group.find_by(slug: slug),
  )

  next unless listing

  create_unit(listing)
end
