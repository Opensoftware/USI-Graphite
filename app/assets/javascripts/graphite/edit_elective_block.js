$(document).ready(function() {
  var base_validation_form = $( "form.elective-block" );
  var base_validation_handler = base_validation_form.validate();

  $("div.content")
  .on("click", "input.save-subject", function() {
    $("input.lazy-validate", "div.elective-subjects").each(function() {
      $(this).rules("add", {
        required:true
      });
    });
    $("input.lazy-validate, select.lazy-validate", "div.elective-blocks").each(function() {
      $(this).rules("remove");
    });
    var context = $("form.save-subject-form");

    if(base_validation_handler.form()) {
      var req = $(this).bindReq({
        context: context,
        dataType: "script",
        serialized_data: [context.serialize(), base_validation_form.find("input:not([name='_method']), select").serialize()].join("&")
      });
      req.bindReq("perform");
    }
    return false;
  })
  .on("click", "input.save-block", function() {
    $("select.lazy-validate, input.lazy-validate", "div.elective-blocks").each(function() {
      $(this).rules("add", {
        required:true
      });
    });
    if($("div.enroll-by-avg-grade input[type='checkbox']").is(":checked")) {
      $('select.student-amount').rules("add", {
        required:true
      });
    } else {
      $('select.student-amount').rules("remove");
    }
    $("input.lazy-validate, select.lazy-validate", "div.elective-subjects").each(function() {
      $(this).rules("remove");
    });
    var context = $("form.save-block-form");

    if(base_validation_handler.form()) {
      var req = $(this).bindReq({
        context: context,
        dataType: "script",
        serialized_data: [context.serialize(), base_validation_form.find("input:not([name='_method']), select").serialize()].join("&")
      });
      req.bindReq("perform");
    }
    return false;
  });

//  elective-block
});