$(document).ready(function() {
  var base_validation_form = $( "form.elective-block" );
  var base_validation_handler = base_validation_form.validate();

  $("div.content")
  .on("click", "input.save-subject", function() {
    $("input.lazy-validate").each(function() {
      $(this).rules("add", {
        required:true
      });
    });
    var context = $("form.save-subject-form");

    if(base_validation_handler.form()) {
      var req = $(this).bindReq({
        context: context,
        dataType: "script",
        serialized_data: [context.serialize(), base_validation_form.find("input:not([name='_method']), select").serialize()].join("&")
      });
      req.bindReq("perform");
    }
    return false;
  });
});