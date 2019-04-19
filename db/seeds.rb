sample_listing_file = File.read 'lib/sample_data/sample_listings.json'
sample_listings = JSON.parse(sample_listing_file)
sample_listings.each do |l|
  Listing.create(l) unless Listing.exists?(listing_id: l['listing_id'])
end
