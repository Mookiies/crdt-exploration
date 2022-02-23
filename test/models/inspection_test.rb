require "test_helper"

class InspectionTest < ActiveSupport::TestCase
  FAKE_TIME = Time.mktime(2000,5,5,5,5,5)
  NODE = '???'
  current_hlc = nil

  setup do
    Time.stubs(:now).returns(FAKE_TIME)
    current_hlc = HybridLogicalClock::Hlc.new(node: NODE).pack
  end

  test "Create record without timestamps" do
    i = Inspection.new(name: 'test')
    assert_nothing_raised do
      i.save!
    end
    assert_equal(current_hlc, i.timestamps['name'])
  end

  test "Create record with timestamps" do
    i = Inspection.new(name: 'test', timestamps: { name: current_hlc })
    assert_nothing_raised do
      i.save!
    end
    assert_equal(current_hlc, i.timestamps['name'])
  end

  # # [[nil, x], [nil, y]] => [server_ts, y]
  # # [[nil, x], [ts, y]] => [ts, y]
  # # [[ts_x, x], [nil, y]] => [server_ts, y]
  # # [[ts_x, x], [ts_y, y]] => x >= y ? [ts_x, x] : [ts_y, y]
  test "change nil wins when no saved ts" do
    #  TODO better way to get timetamps nil without using fixtures?
    new_name = 'new_name!'
    i = Inspection.find(1)
    i.assign_attributes(name: new_name)
    assert_nothing_raised do
      i.save!
    end
    assert_equal(new_name, i.name)
    assert_equal(current_hlc, i.timestamps['name'])
  end

  test "change ts wins when no saved ts" do
    change_hlc = HybridLogicalClock::Hlc.new(node: NODE, now: Time.mktime(2000,1,1,1,1,1).to_i).pack
    new_name = 'new_name!'
    i = Inspection.find(1)
    i.assign_attributes(name: new_name, timestamps: {name: change_hlc})
    assert_nothing_raised do
      i.save!
    end
    assert_equal(new_name, i.name)
    assert_equal(change_hlc, i.timestamps['name'])
  end

  test "change nil wins when saved ts" do
    old_hlc = HybridLogicalClock::Hlc.new(node: NODE, now: Time.mktime(2000,1,1,1,1,1).to_i).pack
    i = Inspection.new(name: 'test', timestamps: {name: old_hlc})
    i.save!

    new_name = 'new_name!'
    i.assign_attributes(name: new_name)
    i.save!
    assert_equal(new_name, i.name)
    assert_equal(current_hlc, i.timestamps['name'])
  end

  test "newer change ts wins when saved ts" do
    old_hlc = HybridLogicalClock::Hlc.new(node: NODE, now: Time.mktime(2000,1,1,1,1,1).to_i).pack
    new_hlc = HybridLogicalClock::Hlc.new(node: NODE, now: Time.mktime(2002,1,1,1,1,1).to_i).pack
    i = Inspection.new(name: 'test', timestamps: {name: old_hlc})
    i.save!

    new_name = 'new_name!'
    i.assign_attributes(name: new_name, timestamps: {name: new_hlc})
    i.save!
    assert_equal(new_name, i.name)
    assert_equal(new_hlc, i.timestamps['name'])
  end

  test "older change ts loses when saved ts" do
    old_hlc = HybridLogicalClock::Hlc.new(node: NODE, now: Time.mktime(2000,1,1,1,1,1).to_i).pack
    new_hlc = HybridLogicalClock::Hlc.new(node: NODE, now: Time.mktime(2002,1,1,1,1,1).to_i).pack
    i = Inspection.new(name: 'test', timestamps: {name: new_hlc})
    i.save!

    new_name = 'new_name!'
    i.assign_attributes(name: new_name, timestamps: {name: old_hlc})
    i.save!
    assert_equal('test', i.name)
    assert_equal(new_hlc, i.timestamps['name'])
  end

  test "prevent timestamps from being independently updated" do
    new_hlc = HybridLogicalClock::Hlc.new(node: NODE, now: Time.mktime(2002,1,1,1,1,1).to_i).pack

    i = Inspection.new(name: 'test', timestamps: {name: current_hlc})
    i.save!

    i.assign_attributes(timestamps: {name: new_hlc})
    i.save!

    assert_equal('test', i.name)
    assert_equal(current_hlc, i.timestamps['name'])
  end
end
