$(document).ready(function() {
  $.validator.addMethod('require-one', function (value) {
    return $('.require-one:checked').size() > 0;
  }, $.validator.messages['required']);
  var checkboxes = $('.require-one');
  var checkbox_names = $.map(checkboxes, function(e,i) {
    return $(e).attr("name")
  }).join(" ");

  var base_validation_form = $( "form.enrollments-form" );
  var base_validation_handler = base_validation_form.validate({
    groups: {
      checks: checkbox_names
    },
    errorPlacement: function(error, element) {
      if (element.attr("type") == "checkbox") {
        error.insertAfter(element.closest("table"));
      } else {
        error.insertAfter(element);
      }
    }
  });

  $("input[type='checkbox']").click(function() {
    $(this).next().val(!$(this).is(":checked"));
  });

  $("input[type='submit']").click(function() {
    if(base_validation_handler.form()) {

    } else {
      return false;
    }
  });

});