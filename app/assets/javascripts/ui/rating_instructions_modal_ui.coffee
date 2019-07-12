
$('.rating_instruction_modal').ready ->

  $('.rating_instruction_modal').addClass('rating_instruction_modal_style');
  $('.modal-overlay').addClass('modal-overlay-style');

  $('.close_rating_modal, .close_modal').click ->
   $('.rating_instruction_modal').removeClass('rating_instruction_modal_style');
   $('.modal-overlay').removeClass('modal-overlay-style');

  $('.instructions').click ->
   $('.rating_instruction_modal').addClass('rating_instruction_modal_style');
   $('.modal-overlay').addClass('modal-overlay-style');

  $('div[data-panelist-status]').each ->
    status = $(this).data('panelist-status')
    if status
      $('.rating_instruction_modal').removeClass('rating_instruction_modal_style');
      $('.modal-overlay').removeClass('modal-overlay-style');
