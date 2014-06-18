$(document).ready(function() {
  var base_validation_form = $( "form.elective-block" );
  var base_validation_handler = base_validation_form.validate();

  $("input.save-subject").click(function() {
    $("input.lazy-validate").each(function() {
      $(this).rules("add", {
        required:true
      });
    });

    if(base_validation_handler.form()) {
      var form = $("form.save-subject-form").clone();
      form.prop("action", form.attr("action")+"?"+$("form.elective-block").serialize());
      $("body").append(form);
      form.submit();
    }
    return false;
  });
});