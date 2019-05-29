class AddGtmKeyToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :gtm_key, :string
  end
end
