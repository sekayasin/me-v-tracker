require "rails_helper"
require "spec_helper"
require "helpers/add_facilitator_helper.rb"
require_relative "../support/add_learner_feature_helper.rb"

describe "Uploading Learner Spreadsheet" do
  include AddFacilitatorHelper
  before :each do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    click_on "Learners"
  end
  before :all do
    create_seed_data
  end

  feature "when uploading learners" do
    scenario "users cannot submit the form if file is not .xlsx" do
      upload_learner_helper("xls_file.xls")
      expect(page).to have_content("Please Upload a .xlsx Spreadsheet file")
    end

    scenario "users cannot submit a form with duplicate emails" do
      upload_learner_helper("duplicate_learner_emails.xlsx")
      expect(page).to have_content(
        "The following email address(es) is/are duplicated:"
      )
    end

    scenario "admin cannot submit a form with duplicate greenhouse ids" do
      upload_learner_helper("duplicate greenhouse.xlsx")
      expect(page).to have_content(
        "The following greenhouse id(s) is/are duplicated:"
      )
    end

    scenario "spreadsheet with wrong length greenhouseIDs can't be submitted" do
      upload_learner_helper("wrong length greenhouseID.xlsx")
      expect(page).to have_content(
        "Greenhouse ID is either empty or of the wrong length"
      )
    end

    scenario "admin cannot submit a spreadsheet with missing email column" do
      upload_learner_helper("no email column.xlsx")
      expect(page).to have_content(
        "email"
      )
    end

    scenario "admin cannot upload a spreadsheet with missing gender
    and ID columns missing" do
      upload_learner_helper("missing gender and ID.xlsx")
      expect(page).to have_content(
        "Greenhouse ID is either empty or of the wrong length", count: 37
      )
      expect(page).to have_content(
        "Gender is missing", count: 35
      )
    end

    scenario "admin cannot upload spreadsheet with invalid emails" do
      upload_learner_helper("invalidlearnerbody.xlsx")
      expect(page).to have_content(
        "Email is invalid", count: 1
      )
    end

    scenario "admin cannot upload spreadsheet if LFAs are missing" do
      upload_learner_helper("invalidlearnerbody.xlsx")
      expect(page).to have_content(
        "LFA is missing for this learner", count: 1
      )
    end

    scenario "admin cannot uploadspreadsheet with wrong information in the
    gender column" do
      upload_learner_helper("invalidlearnerbody.xlsx")
      expect(page).to have_content(
        "A wrong value was entered in the gender field", count: 1
      )
    end

    scenario "admin cannot upload spreadsheet with missing names" do
      upload_learner_helper("missing_names.xlsx")
      expect(page).to have_content(
        "First name is missing", count: 1
      )
      expect(page).to have_content(
        "Last name is missing", count: 1
      )
    end

    scenario "admin can't submit valid spreadsheet with swapped email and
    Gender columns" do
      upload_learner_helper("swapped header columns.xlsx")
      expect(page).to have_content(
        "EmailGender"
      )
    end

    scenario "admin can't upload sheet with missing_headers" do
      upload_learner_helper("missing_headers.xlsx")
      expect(page).to have_content(
        "first namelast nameemailgenderlfagreenhouse candidate id"
      )
    end

    scenario "a new record isn't added to the CycleCenter table
    if the sheet is faulty" do
      expect do
        upload_learner_helper("missing_names.xlsx")
      end.to_not(change { CycleCenter.count })
    end

    scenario "a new record isn't added to the Cycle table
    if the sheet is faulty" do
      expect do
        upload_learner_helper("missing_names.xlsx")
      end.to_not(change { Cycle.count })
    end
  end
end
