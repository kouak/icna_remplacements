class CreateRequestsTeamsTable < ActiveRecord::Migration
  def change
    create_table :requests_teams_tables do |t|
      t.integer :request_id
      t.integer :team_id
    end
  end
end
