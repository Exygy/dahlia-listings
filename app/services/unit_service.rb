# frozen_string_literal: true

# Unit data operations
class UnitService
  class << self
    def unit_type_group_summary(unit_type, units)
      {
        min_income_range: min_max_range(units, :monthly_income_min),
        occupancy_range: occupancy_range(units),
        rent_as_percent_income_range: min_max_range(
          units,
          :monthly_rent_as_percent_of_income,
        ),
        rent_range: monthly_rent_range(units),
        unit_type: I18n.t("unit_types.#{unit_type}"),
      }
    end

    private

    def min_max_range(units, field_name)
      field_values = units.map { |u| u.send(field_name) }

      begin
        { min: field_values.min, max: field_values.max }
      rescue ArgumentError
        {}
      end
    end

    def occupancy_range(units)
      min_occupancy = units.map(&:min_occupancy).min
      max_occupancy = units.map(&:max_occupancy).max
      { min: min_occupancy, max: max_occupancy }
    end

    def monthly_rent_range(units)
      range = min_max_range(units, :monthly_rent)
      range[:min] = range[:min]&.to_i
      range[:max] = range[:max]&.to_i
      range
    end
  end
end
