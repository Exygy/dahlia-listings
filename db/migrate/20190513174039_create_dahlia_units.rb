class CreateDahliaUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :units do |t|
      t.decimal :ami_percentage, precision: 5, scale: 2
      t.integer :ami_chart_type
      t.integer :ami_chart_year
      t.decimal :bmr_annual_income_min, precision: 8, scale: 2
      t.decimal :bmr_monthly_income_min, precision: 8, scale: 2
      t.decimal :max_household_income, precision: 8, scale: 2
      t.integer :max_occupancy
      t.integer :min_occupancy
      t.decimal :monthly_rent, precision: 8, scale: 2
      t.integer :num_bathrooms
      t.integer :num_bedrooms
      t.integer :priority_type
      t.integer :reserved_type
      t.integer :status
      t.integer :floor
      t.string  :number
      t.integer :sq_ft
      t.integer :unit_type

      t.timestamps
    end

    add_reference :units, :listing, foreign_key: true
  end
end