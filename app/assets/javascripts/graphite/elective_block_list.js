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
  });

  $("button.destroy-all").lazy_form_confirmable_action({
    topic: 'confirmation_elective_blocks_delete',
    success_action: function(obj, key, val) {
      $("#elective-block-"+key).remove();
    }
  });
});