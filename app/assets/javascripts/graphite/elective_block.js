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

  var send_req = function() {
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
      serialized_data: base_validation_form.serialize()
    });
    req.bindReq("perform");
  };
  $("div.content")
  .on("click", "button.cancel-form", function() {
    var context = $("form.new-"+$(this).data("type")+"-form");
    var req = $(this).bindReq({
      context: context,
      dataType: "script",
      request: {
        type: "GET"
      },
      serialized_data: [context.serialize(), base_validation_form.find("input:not([name='_method']), select").serialize()].join("&")
    });
    req.bindReq("perform");
    return false;
  })
  .on("click", "a.edit-element", function() {
    send_req.call(this);
    return false;
  })
  .on("click", "a.destroy-element", function() {
    $(this).yesnoDialog({
      topic: $.i18n._('confirmation_action_delete_element'),
      confirmation_action: function() {
        var that = this;
        this.footer.find("button.btn-confirmation").click(function() {
          send_req.call(that.element);
          $("div.modal").modal("hide");
        });
      }
    });
    $(this).yesnoDialog("show");
    return false;
  });

  $("input.save-and-close").click(function() {
    var context = $(this).closest("form");
    $("input.lazy-validate, select.lazy-validate").each(function() {
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