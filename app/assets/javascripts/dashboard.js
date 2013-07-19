//= require fullcalendar
//= require fullcalendar-fr

$(document).ready(function() {
  $('#calendar').fullCalendar($.extend({ 
      editable: false,
      eventSources: [{
        url: '/events.json'
      }],
      eventRender: function (event, element, view) {
        element.popover({
          placement: 'right',
          title: event.title,
          content: 'text',
          container: 'body' // This is needed to make popovers visible outside the boundaries of the container
        });

        $('body').on('click', function (e) { // This magic is here to remove popovers when a new one appears
          if (!element.is(e.target) && element.has(e.target).length === 0 && $('.popover').has(e.target).length === 0)
            element.popover('hide');
        });
      }
    },
    fullcalendarfr_Options)
  );
});