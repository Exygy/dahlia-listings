class CreateDahliaGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :slug
      t.string :domain
      t.integer :group_type
      t.integer :parent_id, :null => true, :index => true
      t.integer :lft, :null => false, :index => true
      t.integer :rgt, :null => false, :index => true
      t.integer :depth, :null => false, :default => 0
      t.integer :children_count, :null => false, :default => 0

      t.timestamps
    end

    add_reference :listings, :group, foreign_key: true

    if defined? User
      add_reference :users, :group, foreign_key: true
    end
  end
end
