json.(@single_events.each) do |single_event|
  json.partial! single_event
end