module SalesforceService
  # encapsulate all Salesforce ShortForm querying functions
  class ShortFormService < SalesforceService::Base
    def self.check_household_eligibility(listing_id, params)
      endpoint = "/Listing/EligibilityCheck/#{listing_id}"
      %i(householdsize childrenUnder6).each do |k|
        params[k] = params[k].present? ? params[k].to_i : 0
      end
      %i(incomelevel).each do |k|
        params[k] = params[k].present? ? params[k].to_f : 0
      end
      cached_api_get(endpoint, params)
    end

    def self.create_or_update(params, contact_attrs)
      params[:primaryApplicant].merge!(contact_attrs)
      api_post('/shortForm', params)
    end

    def self.get(id)
      api_get("/shortForm/#{id}")
    end

    def self.get_for_user(contact_id)
      apps = api_get("/shortForm/list/#{contact_id}")
      apps.compact.sort_by { |app| app['applicationSubmittedDate'] || '0' }.reverse
    end

    def self.find_listing_application(opts = {})
      applications = get_for_user(opts[:contact_id])
      application = applications.find do |app|
        app['listingID'] == opts[:listing_id]
      end
      if !application && opts[:autofill]
        application = autofill(applications, opts[:listing_id])
      end
      application
    end

    def self.autofill(applications, listing_id)
      # applications were already sorted by most recent in get_for_user
      application = applications.find do |app|
        app['status'] == 'Submitted'
      end
      application = autofill_reset(application, listing_id) if application
      application
    end

    def self.autofill_reset(application, listing_id)
      application = Hashie::Mash.new(application.as_json)
      reset = {
        autofill: true,
        id: nil,
        listingID: listing_id,
        status: 'Draft',
        applicationSubmittedDate: nil,
        answeredCommunityScreening: nil,
        lotteryNumber: nil,
        name: nil,
        agreeToTerms: nil,
        shortFormPreferences: [],
      }
      # reset income fields on apps > 30 days old
      if Date.parse(application[:applicationSubmittedDate]) < 30.days.ago
        reset[:householdVouchersSubsidies] = nil
        reset[:annualIncome] = nil
        reset[:monthlyIncome] = nil
      end
      application.merge(reset)
    end

    def self.delete(id)
      api_delete("/shortForm/delete/#{id}")
    end

    def self.attach_file(application, file, filename)
      headers = { Name: filename, 'Content-Type' => file.content_type }
      endpoint = "/shortForm/Attachment/#{application['id']}"
      body = {
        fileName: filename,
        DocumentType: file.document_type,
        Body: Base64.encode64(file.file),
        ApplicationId: application['id'],
        ApplicationMemberID: _short_form_pref_member_id(application, file),
        ApplicationPreferenceID: _short_form_pref_id(application, file),
      }
      Rails.logger.info "Api::V1::ShortFormService.attach_file Parameters: #{body}"
      api_post_with_headers(endpoint, body, headers)
    end

    def self.queue_file_attachments(application_id, files)
      files.each do |file|
        ShortFormAttachmentJob.perform_later(application_id, file.id)
      end
    end

    def self.ownership?(contact_id, application)
      contact_id == application['primaryApplicant']['contactId']
    end

    def self.can_claim?(session_uid, application)
      return false unless application['status'].casecmp('submitted').zero?
      metadata = JSON.parse(application['formMetadata'])
      # only claimable if they are in the same user session
      session_uid == metadata['session_uid']
    rescue
      false
    end

    def self.submitted?(application)
      application['status'] == 'Submitted'
    end

    def self._short_form_pref_id(application, file)
      _short_form_pref(application, file).try(:[], 'shortformPreferenceID')
    end

    def self._short_form_pref_member_id(application, file)
      _short_form_pref(application, file).try(:[], 'appMemberID')
    end

    def self._short_form_pref(application, file)
      application['shortFormPreferences'].find do |preference|
        preference['listingPreferenceID'] == file.listing_preference_id
      end
    end
  end
end
