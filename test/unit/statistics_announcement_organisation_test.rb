require 'test_helper'

class StatisticsAnnouncementOrganisationTest < ActiveSupport::TestCase
  test "should be invalid without a statistics announcement" do
    statistics_announcement_organisation = StatisticsAnnouncementOrganisation.new(organisation: build(:organisation))

    refute statistics_announcement_organisation.valid?
    assert_include statistics_announcement_organisation.errors[:statistics_announcement], "can't be blank"
  end

  test "should be invalid without an organisation" do
    statistics_announcement_organisation = StatisticsAnnouncementOrganisation.new(statistics_announcement: build(:statistics_announcement))

    refute statistics_announcement_organisation.valid?
    assert_include statistics_announcement_organisation.errors[:organisation], "can't be blank"
  end
end
