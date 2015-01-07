require 'test_helper'

class SluggingTest < ActiveSupport::TestCase

  test "generates a slug for a sluggable model" do
    gareth = create(:person, forename: 'Gareth', surname: 'Owen')

    assert_equal 'gareth-owen', gareth.slug
  end

  test "appends a sequence number when the slug is already taken" do
    gareth_1, gareth_2, gareth_3 = (1..4).map { create(:person, forename: 'Gareth', surname: 'Owen') }

    assert_equal 'gareth-owen', gareth_1.slug
    assert_equal 'gareth-owen--2', gareth_2.slug
    assert_equal 'gareth-owen--3', gareth_3.slug
  end
end
