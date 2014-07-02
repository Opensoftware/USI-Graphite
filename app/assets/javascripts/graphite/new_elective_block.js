$(document).ready(function() {
  var base_validation_form = $( "form.elective-block" );
  var base_validation_handler = base_validation_form.validate();

  $("input.save-subject").click(function() {
    $("input.lazy-validate", "div.elective-subjects").each(function() {
      $(this).rules("add", {
        required:true
      });
    });
    $("input.lazy-validate, select.lazy-validate", "div.elective-blocks").each(function() {
      $(this).rules("remove");
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