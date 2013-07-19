json.(@single_events.each) do |single_event|
  json.partial! 'single_events/single_event', :single_event => single_event
end