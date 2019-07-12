class DlcStackController < ApplicationController
  def show_program_dlc_stack
    dlc_stacks = DlcStack.show_program_dlc_stack(params[:program_id])

    render json: filter_stacks(dlc_stacks)
  end

  private

  def filter_stacks(dlc_stacks)
    all_dlc_stacks = []
    dlc_stacks.each do |dlc_stack|
      program_dlc_stack = {
        dlc_stack_id: dlc_stack.id,
        dlc_stack_name: dlc_stack.language_stack.name
      }
      all_dlc_stacks << program_dlc_stack
    end

    all_dlc_stacks
  end
end
