class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.integer :team

      t.timestamps
    end
  end
end
