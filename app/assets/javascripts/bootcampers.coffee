# # Code for homepage dropdowns
# #= require jquery
# #= require jquery_ujs
# #= require puffly
# #= require_tree .

$(document).ready ->
    editLearnerTechnicalDetails = new EditLearnerTechnicalDetails.App();
    editLearnerTechnicalDetails.start()
