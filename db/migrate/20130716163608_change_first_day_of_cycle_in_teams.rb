class ChangeFirstDayOfCycleInTeams < ActiveRecord::Migration
  def change
    change_table :teams do |t|
      t.remove :first_day_in_cycle
      t.datetime :first_day_in_cycle
    end
  end
end
