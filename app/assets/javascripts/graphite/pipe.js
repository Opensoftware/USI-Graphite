$(document).ready(function() {

  setTimeout(function() {
    var ctxt = $("div.student-elective-enrollments");
    var source = new EventSource(ctxt.data("pipe"));
    source.addEventListener('refresh', function(e) {
      var response = JSON.parse(e.data);
      if("elective_block_id" in response) {
        $("#elective-module-"+response.elective_block_id).find("div.enrollment-status > p").html(response.message);
      }
    });
    return true;
  }, 50);

});