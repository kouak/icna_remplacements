class CreateRequestsTeamsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :teams, :requests do |t|
      t.index [:team_id, :request_id]
      t.index [:request_id, :team_id]
    end
  end
end
