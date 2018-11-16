/* When the Request button is clicked for a TRLN result, show */
/* a modal with links to choose your home library. Add the    */
/* corresponding ILLiad request parameters to those links.    */
$(document).ready(function() {

  $(document).on("click", ".request-from-trln", function () {
    var illiad_params = $(this).data('illiad-params');
    $( "#choose-your-illiad a" ).each(function(){
      new_href = ($(this).data('base-url') + '?' + illiad_params);
      $(this).attr( "href", new_href );
    });
  });

});
