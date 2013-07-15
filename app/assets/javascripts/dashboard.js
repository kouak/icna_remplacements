//= require fullcalendar
//= require fullcalendar-fr

$(document).ready(function() {
  $('#calendar').fullCalendar($.extend({ 
      editable: false
    },
    fullcalendarfr_Options)
  );
});