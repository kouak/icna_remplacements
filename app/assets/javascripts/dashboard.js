//= require fullcalendar
//= require fullcalendar-fr

$(document).ready(function() {
  $('#calendar').fullCalendar($.extend({ 
      editable: false,
      eventSources: [{
        url: '/events.json'
      }]
    },
    fullcalendarfr_Options)
  );
});