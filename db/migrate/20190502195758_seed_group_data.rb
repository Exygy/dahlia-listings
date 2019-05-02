class SeedGroupData < ActiveRecord::Migration[5.2]
  def up
    if Group.count == 0
      Group.create(name: 'San Mateo County', slug: 'smc', domain: 'herokuapp.com', group_type: :county)
      Group.create(name: 'San Jose', slug: 'sj', domain: 'localhost')
    end
  end
end
