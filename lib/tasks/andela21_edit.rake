namespace :app do
  desc "Update Andela21 save status to false"
  task set_andela21_save_status: :environment do
    andela21 = Program.find_by(name: "Andela21 v0.1")
    unless andela21.nil?
      andela21.update(save_status: false)
      puts "Andela 21 save status updated to false successfully"
    end
  end
end
