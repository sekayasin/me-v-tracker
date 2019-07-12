class ChangeColumnCriteridIdToCriteriumId < ActiveRecord::Migration[5.0]
  def change
    rename_column :assessments, :criteria_id, :criterium_id
  end
end
