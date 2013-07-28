class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :owner_id
      t.datetime :date

      t.timestamps
    end
  end
end
