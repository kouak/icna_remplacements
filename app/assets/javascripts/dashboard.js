//= require fullcalendar
//= require fullcalendar-fr

$(document).ready(function() {
  $('#calendar').fullCalendar($.extend({ 
      editable: false,
      eventSources: [{
        url: '/single_events/stub.json'
      }]
    },
    fullcalendarfr_Options)
  );
});