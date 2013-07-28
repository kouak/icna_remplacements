json.array!(@teams) do |team|
  json.extract! team, :team
  json.url team_url(team, format: :json)
end
