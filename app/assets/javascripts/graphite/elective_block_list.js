$(document).ready(function() {
  $("div.elements-list")
  .on("click", "button.button-delete", function() {
    $(this).yesnoDialogRemote({
      topic: $.i18n._('confirmation_elective_block_delete')
    });
    $(this).yesnoDialogRemote("show");
  })
  .on("checkbox-change-state", "button.button-checkbox", function() {
    $(this).toggleClass('button-small-checkbox-selected');
    $(this).next().prop('disabled', !$(this).next().is(":disabled"));
  })
  .on("checkbox-uncheck", "button.button-checkbox", function() {
    $(this).removeClass('button-small-checkbox-selected');
    $(this).next().prop('disabled', true);
  })
  .on("click", "button.button-checkbox", function() {
    $(this).trigger("checkbox-change-state");
  })
  .on("click", "a.button-perform-scheduling", function() {
    if(!$(this).hasClass("disabled")) {
      $(this).yesnoDialogRemote({
        topic: $.i18n._('confirmation_elective_blocks_scheduler'),
        confirmation_action: function() {
          var that = this;
          this.footer.find("button.btn-confirmation").click(function() {
            var ctxt = $("form.elective-blocks-form");
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

  $("button.destroy-all").lazy_form_confirmable_action({
    topic: 'confirmation_elective_blocks_delete',
    success_action: function(obj, key, val) {
      $("#elective-block-"+key).remove();
    }
  });
});