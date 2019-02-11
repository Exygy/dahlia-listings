# frozen_string_literal: true

module Force
  # encapsulate all Salesforce Listing querying functions
  class ListingService
    WHITELIST_BROWSE_FIELDS = %i[
      Id
      listingID
      Tenure
      Name
      Application_Due_Date
      Accepting_Online_Applications
      Lottery_Date
      Lottery_Results
      Lottery_Results_Date
      Reserved_community_type
      Reserved_community_minimum_age
      reservedDescriptor
      prioritiesDescriptor
      hasWaitlist
      Units_Available
      unitSummaries
      Does_Match
      LastModifiedDate
      imageURL
      Tenure
    ].freeze
    TEST_SALE_LISTING_ID = 'a0W21000007AWriEAG'
    # get all open listings or specific set of listings by id
    # `ids` is a comma-separated list of ids
    # returns cached and cleaned listings
    def self.listings(attrs = {})
      params = attrs[:ids].present? ? { ids: attrs[:ids] } : nil
      results = get_listings(params)
      # TODO: Remove stubbed listing data when fields are available on Salesforce.
      results.each do |result|
        stub_sale_listing_data(result) if result['listingID'] == TEST_SALE_LISTING_ID
      end
      # TODO: Move filtering to saleforce request
      results = filter_listings(results, attrs) if attrs.present?
      clean_listings_for_browse(results)
    end

    def self.raw_listings(opts = {})
      force = opts[:refresh_cache] || false
      Request.new(parse_response: true).cached_get('/ListingDetails', nil, force)
    end

    # get listings with eligibility matches applied
    # filters:
    #  householdsize: n
    #  incomelevel: n
    #  childrenUnder6: n
    def self.eligible_listings(filters)
      results = get_listings(filters)
      results = clean_listings_for_browse(results)
      # sort the matched listings to the top of the list
      results.partition { |i| i['Does_Match'] }.flatten
    end

    # get one detailed listing result by id
    def self.listing(id, opts = {})
      endpoint = "/ListingDetails/#{CGI.escape(id)}"
      force = opts[:force] || false
      results = Request.new(parse_response: true).cached_get(endpoint, nil, force)
      result = add_image_urls(results).first
      # TODO: Remove stubbed out listing when fields are available on Salesforce.
      stub_sale_listing_data(result) if id == TEST_SALE_LISTING_ID
      result
    end

    # get all units for a given listing
    def self.units(listing_id, opts = {})
      esc_listing_id = CGI.escape(listing_id)
      force = opts[:force] || false
      Request.new(parse_response: true)
             .cached_get("/Listing/Units/#{esc_listing_id}", nil, force)
    end

    # get all preferences for a given listing
    def self.preferences(listing_id, opts = {})
      esc_listing_id = CGI.escape(listing_id)
      force = opts[:force] || false
      Request.new(parse_response: true)
             .cached_get("/Listing/Preferences/#{esc_listing_id}", nil, force)
    end

    # get AMI: opts are percent, chartType, year
    def self.ami(opts = {})
      results = Request.new(parse_response: true).cached_get("/ami?#{opts.to_query}")
      results.sort_by { |i| i['numOfHousehold'] }
    end

    def self.ami_charts
      Request.new.get('/ami/charts')
    end

    # get Lottery Buckets with rankings
    def self.lottery_buckets(listing_id, opts = {})
      esc_listing_id = CGI.escape(listing_id)
      force = opts[:force] || false
      data = Request.new
                    .cached_get("/Listing/LotteryResult/#{esc_listing_id}", nil, force)
      # cut down the bucketResults so it's not a huge JSON
      data['lotteryBuckets'] ||= []
      data['lotteryBuckets'].each do |bucket|
        bucket['preferenceResults'] = bucket['preferenceResults'].slice(0, 1)
      end
      data
    end

    # get Individual Lottery Result with rankings
    def self.lottery_ranking(listing_id, lottery_number)
      esc_listing_id = CGI.escape(listing_id)
      esc_lottery_number = CGI.escape(lottery_number)
      endpoint = "/Listing/LotteryResult/#{esc_listing_id}/#{esc_lottery_number}"
      Request.new.get(endpoint)
    end

    def self.check_household_eligibility(listing_id, params)
      listing_id = CGI.escape(listing_id)
      endpoint = "/Listing/EligibilityCheck/#{listing_id}"
      %i[household_size incomelevel].each do |k|
        params[k] = params[k].to_i if params[k].present?
      end
      Request.new.get(endpoint, params)
    end

    def self.array_sort!(listing)
      listing.each do |k, v|
        listing[k] = v.sort_by { |i| i['Id'] } if v.is_a?(Array) && v[0] && v[0]['Id']
      end
    end

    private_class_method def self.get_listings(params = nil)
      results = Request.new(parse_response: true).cached_get('/ListingDetails', params)
      add_image_urls(results)
    end

    private_class_method def self.add_image_urls(listings)
      listing_images = ListingImage.all
      listings.each do |listing|
        listing_image = listing_images.select do |li|
          li.salesforce_listing_id == listing['Id']
        end.first
        # fallback to Building_URL for the case where ListingImages have not been set up
        url = listing_image ? listing_image.image_url : listing['Building_URL']
        listing['imageURL'] = url
      end
      listings
    end

    private_class_method def self.clean_listings_for_browse(results)
      results.map do |listing|
        listing.select do |key|
          WHITELIST_BROWSE_FIELDS.include?(key.to_sym) || key.include?('Building')
        end
      end
    end

    # TODO: Remove this method when we no longer need to stub data.
    private_class_method def self.stub_sale_listing_data(listing)
      # Add stubbed listing fields
      # rubocop:disable LineLength
      stubbed_listing_data = {
        'Allows_Realtor_Commission' => true,
        'Realtor_Commission_Percentage' => 15,
        'Realtor_Commission_Info' => 'TBD but this will probably be a shortish string',
        'CC_and_R_URL' => 'http://www.google.com',
        'Repricing_Mechanism' => 'TODO: Replace this with a real example of a repricing mechanism. Here\'s some sample text with links <a href=\"http://sf-moh.org/index.aspx?page=295\" target=\"_blank\">Inclusionary Affordable Housing Program Monitoring and Procedures Manual 2013</a>',
        'Expected_Move_in_Date' => '2019-12-20',
        'Appliances' => 'TODO: Replace this with a real example of a list of available appliances.',
        'Parking_Information' => 'TODO: Replace this with a real example of parking information. It might be a fairly long paragraph',
        'Multiple_Listing_Service_URL' => 'http://www.google.com',
        'Housing_Program_Name' => 'TBD what this is',
      }
      # rubocop:enable LineLength
      listing.merge!(stubbed_listing_data)

      listing
    end

    private_class_method def self.filter_listings(results, filter)
      results = results.collect(&:with_indifferent_access)
      filter.except(:ids).each do |key, value|
        results = case key.to_sym
                  when :Tenure
                    case value
                    when 'rental'
                      results.select do |listing|
                        listing[key] == 'New rental' || listing[key] == 'Re-rental'
                      end
                    when 'sale'
                      results.select do |listing|
                        listing[key] == 'New sale' || listing[key] == 'Resale'
                      end
                    else
                      results
                    end
                  else
                    results
                  end
      end
      results
    end
  end
end
