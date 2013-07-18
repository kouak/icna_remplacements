class AddOverrideCycleToSingleEvent < ActiveRecord::Migration
  def change
    add_column :single_events, :override_cycle, :boolean, :default => false
  end
end
