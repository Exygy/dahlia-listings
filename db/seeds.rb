# sample_listing.json is a copy of the listing API endpoint response
# returned by Salesforce in the original DAHLIA. we're using it as a
# quick way to get some test listing data while SMC/SJ DAHLIA is in
# early development.
sample_listing_file = File.read 'lib/sample_data/sample_listing.json'
sample_listing_salesforce_fields = JSON.parse(sample_listing_file)
listing = Listing.new
listing.add_fields(sample_listing_salesforce_fields, :salesforce)
Listing.create listing.to_domain.to_hash
