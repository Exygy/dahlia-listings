# frozen_string_literal: true

# Listing data operations
class ListingService
  def self.create_unit_summaries(listing = nil)
    return false unless listing

    units = listing.units
    return false unless units

    # FIXME: Implement actual logic to go over all units of a listing and
    # create a summary. Unit summary is hardcoded here to work with demo data.
    {
      reserved: nil,
      general: [
        {
          unitType: 'Studio',
          totalUnits: 1,
          priorities: nil,
          minSquareFt: 559,
          minRentalMinIncome: 3800,
          minPriceWithParking: nil,
          minPriceWithoutParking: nil,
          minPercentIncome: nil,
          minOccupancy: 1,
          minMonthlyRent: 1900,
          minHoaDuesWithParking: nil,
          minHoaDuesWithoutParking: nil,
          maxSquareFt: 559,
          maxRentalMinIncome: 3800,
          maxPriceWithParking: nil,
          maxPriceWithoutParking: nil,
          maxPercentIncome: nil,
          maxOccupancy: 2,
          maxMonthlyRent: 1900,
          maxHoaDuesWithParking: nil,
          maxHoaDuesWithoutParking: nil,
          listingID: listing.id,
        },
      ],
    }
  end
end
