class CreateSingleEvents < ActiveRecord::Migration
  def change
    create_table :single_events do |t|
      t.string :name
      t.datetime :starttime
      t.datetime :endtime
      t.boolean :all_day
      t.string :description
      t.integer :user_id

      t.timestamps
    end
  end
end
