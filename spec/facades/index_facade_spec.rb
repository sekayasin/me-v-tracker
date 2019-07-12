require "rails_helper"

RSpec.describe IndexFacade, type: :facade do
  let!(:facilitor1) do
    create :facilitator, email: "onyekachi.okereke@andela.com"
  end

  let!(:facilitor2) do
    create :facilitator, email: "robs.ron@andela.com"
  end

  let(:facade_object) { IndexFacade.new(size: 10) }

  describe "filter out lfas" do
    let(:week_one_filter) { :week_one_lfa }
    let(:week_two_filter) { :week_two_lfa }
    let(:query) do
      { program_id: 4, city: "Lagos", cycle: 34,
        week_one_lfa: facilitor1.email, week_two_lfa: "All" }
    end

    let(:week_two_query) do
      { program_id: 4, city: "Lagos", cycle: 34,
        week_one_lfa: "All", week_two_lfa: facilitor2.email }
    end

    context "when filter is passed in containing a week one lfa" do
      it "returns the week one lfa's id" do
        expect(facade_object.filter_out_lfas(week_one_filter, query)).to eq(
          [facilitor1.id]
        )
      end
    end

    context "when filter is passed in containing a week two lfa" do
      it "returns the week two lfa's id" do
        expect(facade_object.filter_out_lfas(
                 week_two_filter, week_two_query
              )).to eq [facilitor2.id]
      end
    end
  end
end
