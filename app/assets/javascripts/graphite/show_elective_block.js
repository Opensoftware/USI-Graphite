$(document).ready(function() {
  $(".button-delete").click(function() {
    $(this).yesnoDialog({
      topic: $.i18n._('confirmation_elective_block_delete')
    });
    $(this).yesnoDialog("show");
    return false;
  });
  $("a.button-perform-scheduling").click(function() {
    if(!$(this).hasClass("disabled")) {
      $(this).yesnoDialogRemote({
        topic: $.i18n._('confirmation_elective_blocks_scheduler'),
        confirmation_action: function() {
          var that = this;
          this.footer.find("button.btn-confirmation").click(function() {
            var ctxt = $("form.enrollments-form");
            var form = $("<form method='post'/>");
            form.append($("<input name='_method' >").val(that.element.data("method")))
            .append(ctxt.find("input[name='authenticity_token']"));
            form.prop("action", that.element.prop('href'));
            $("body").append(form);
            form.submit();
          });
        }
      });
      $(this).yesnoDialogRemote("show");
    }
    return false;
  });

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