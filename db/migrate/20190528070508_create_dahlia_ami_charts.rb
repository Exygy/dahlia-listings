class CreateDahliaAmiCharts < ActiveRecord::Migration[5.2]
  def change
    create_table :ami_charts do |t|
      t.string :ami_values_file
      t.integer :chart_type
      t.integer :year

      t.timestamps
    end

    add_reference :ami_charts, :group, foreign_key: true

    add_index :ami_charts, [:chart_type, :year, :group_id], unique: true

    remove_column :units, :ami_chart_type, :integer
    remove_column :units, :ami_chart_year, :integer

    add_reference :units, :ami_chart, foreign_key: true
  end
end
