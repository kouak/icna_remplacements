class AddFirstDayInCycleToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :first_day_in_cycle, :date
  end
end
