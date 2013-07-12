class AddMultipleColumnsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :team_id, :integer
  	add_column :users, :detailed, :boolean, :default => false
  	add_column :users, :first_name, :string, :null => false, :default => ''
  	add_column :users, :surname, :string, :null => false, :default => ''
  	add_column :users, :name, :string, :null => false, :default => ''
  end
end
