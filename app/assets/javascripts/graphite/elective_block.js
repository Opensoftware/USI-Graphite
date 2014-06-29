$(document).ready(function() {
  var base_validation_form = $( "form.elective-block" );
  var base_validation_handler = base_validation_form.validate();

  $("select.block-type").change(function() {
    var ctxt = $("div.elective-blocks");
    ctxt.toggle(function() {
      return $(this).find("option:eq("+$(this).prop("selectedIndex")+")").val() ==
      ctxt.data("block_type_id");
    });
  });

  $("div.content")
  .on("click", "a.edit-subject, a.destroy-subject", function() {

    var that = $(this);
    var req = $(this).bindReq({
      context: base_validation_form,
      dataType: "script",
      url: function() {
        return that.prop("href");
      },
      request: {
        type: that.data("method") || "GET"
      },
      serialized_data: "&"
    });
    req.bindReq("perform");
    return false;
  });

  $("input.save-and-close").click(function() {
    var context = $(this).closest("form");
    $("input.lazy-validate").each(function() {
      $(this).rules("remove");
    });

    if(base_validation_handler.form()) {
      var form = $("<form method='post'/>");
      form.append($("form.elective-block").find("input[name='_method']"));
      form.prop("action", context.prop("action")+"?"+[$("form.elective-block").serialize(), context.serialize()].join("&"));
      $("body").append(form);
      form.submit();
    }
    return false;
  });

});