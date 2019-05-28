# frozen_string_literal: true

# Create test data as well as the placeholder groups and listings that we're
# using to represent the real SMC and SJ groups and listings. Once Phase 1
# of regional DAHLIA is launched, we will have finalized the actual data
# for the real SMC and SJ groups and listings and will remove the SMC and SJ
# placeholder data. We will keep the test data and add more test data.

def parse_from_json_file(filename)
  json_file_str = File.read "db/seed_data/#{filename}"
  JSON.parse(json_file_str)
end

def create_groups
  groups_fields = parse_from_json_file('groups.json')
  groups_fields.each do |fields|
    next if Group.exists?(slug: fields['slug'])
    Group.create(fields)
  end

  return if Group.exists?(slug: 'test')
  Group.create(
    name: 'Test Group',
    slug: 'test',
    domain: Rails.env.production? ? 'herokuapp.com' : 'localhost',
  )
end

def create_unit(listing)
  unit_fields = parse_from_json_file('unit.json')
  unit = Unit.create(unit_fields)
  unit.listing = listing
  unit.save
end

def create_listing_from_file(filename, group)
  listing_fields = parse_from_json_file(filename)

  return false if Listing.exists?(listing_id: listing_fields['listing_id'])

  listing = Listing.create(listing_fields)
  listing.group = group
  listing.save

  create_unit(listing) if listing
end

def create_listings
  %w[sj smc test].each do |slug|
    create_listing_from_file(
      "#{slug}_listing.json",
      Group.find_by(slug: slug),
    )
  end
end

def create_test_user
  return unless defined?(User) && Rails.env.test?
  User.find_or_create_by(email: ENV['E2E_TEST_USER_EMAIL'] || 'test@domain.com') do |user|
    user.password = ENV['E2E_TEST_USER_PASSWORD'] || 'dc29b69cb66321f'
    user.group = Group.find_by_domain('localhost')
  end
end

create_groups
create_listings
create_test_user
