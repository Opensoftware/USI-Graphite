$(document).ready(function() {
  $.validator.addMethod('require-amount', function (value) {
    var size = $('.require-amount:checked').size();
    return size == $("h6.block-type").data("elective-block-subjects-amount");
  }, $.validator.format(pl_translations['validator_match_subject_amount'], $("h6.block-type").data("elective-block-subjects-amount")));
  var checkboxes = $('.require-amount');
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