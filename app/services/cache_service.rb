# service class for pre-fetching + caching salesforce data
class CacheService
  ListingService = SalesforceService::ListingService

  def self.prefetch_listings(opts = {})
    if opts[:refresh_all]
      # on daily run, don't grab old listings for comparison
      # to force cache write for all listings
      old_listings = []
    else
      # grab previous cached result
      old_listings = ListingService.listings(nil, false)
    end
    # refresh oauth_token before beginnning
    ListingService.oauth_token(true)
    # set requests to force cache write (if we `cache_single_listing`)
    ListingService.force = true
    new_listings = ListingService.listings(nil, false)

    new_listings.each do |listing|
      id = listing['Id']
      old = old_listings.find { |l| l['Id'] == id }
      unchanged = false
      if old.present?
        old = ListingService.array_sort!(old)
        listing = ListingService.array_sort!(listing)
        # NOTE: This comparison isn't perfect, as the browse listings API endpoint doesn't
        # contain some relational data e.g. some individual unit/preference details.
        # That's why we more aggressively re-cache open listings.
        unchanged = HashDiff.diff(old, listing).empty?
      end
      begin
        due_date_passed = Date.parse(listing['Application_Due_Date']) < Date.today
      # to do: specify error class to rescuing
      rescue
        due_date_passed = true
      end
      # move on if there is no difference between the old and new listing object
      # but always refresh open listings
      next if unchanged && due_date_passed
      cache_single_listing(listing, due_date_passed)
    end

    ListingService.force = false
  end

  def self.cache_single_listing(listing, due_date_passed = true)
    id = listing['Id']
    # cache this listing from API
    ListingService.listing(id)
    ListingService.units(id)
    ListingService.preferences(id)
    ListingService.lottery_buckets(id) if due_date_passed
    # NOTE: there is no call to ListingService.ami
    # because it is parameter-based and values will rarely change (1x/year?)
    image_processor = ListingImageService.new(listing).process_image
    Rails.logger.error image_processor.errors.join(',') if image_processor.errors.present?
  rescue Faraday::ClientError => e
    Raven.capture_exception(e, tags: { 'listing_id' => listing['Id'] })
  end
end
