Blacklight.onLoad(function() {  
  // If add relevant classes to document headers if bookmarks or thumbnails are present
  // We'll use this for calculating the width of the document header title      
  $(window).load(function(){      
    $('#documents div.blacklight.thumbnail.valid-thumbnail')
       .siblings('.documentHeader').addClass('has-thumbnail');      
       // TODO: do something similar here for bookmarks
    });
  });