$(document).ready(function() {
  $("div.elements-list")
  .on("click", "button.button-delete", function() {
    $(this).yesnoDialogRemote({
      topic: $.i18n._('confirmation_elective_block_delete')
    });
    $(this).yesnoDialogRemote("show");
  });
});