class AddMonthlyRentPercentageToUnits < ActiveRecord::Migration[5.2]
  def change
    add_column :units, :monthly_rent_as_percent_of_income, :integer
  end
end
