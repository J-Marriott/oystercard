require 'oystercard'

describe Oystercard do
  let(:oystercard) {described_class.new}
  let(:entry_station) { double :station }
  let(:exit_station) { double :station }
  let(:journey) { {from: entry_station, to: exit_station} }

  describe "#initialize" do
    it "Checks that balance initializes value = 0" do
      expect(oystercard.balance).to eq 0
    end
    it "Checks card limit initializes to £90" do
      expect(oystercard.limit).to eq 90
    end
  end

  describe "#top_up" do
    it "Tops up the balance of an Oystercard" do
      expect(oystercard.top_up(50)).to eq 50
    end

    it "Refuse topup if limit will be exceeded" do
      error = "Deposit would exceed max limit of #{Oystercard::DEFAULT_LIMIT}"
      deposit = Oystercard::DEFAULT_LIMIT + 1
      expect{oystercard.top_up(deposit)}.to raise_error error
    end
  end

  describe "#touch_in(entry_station)" do
    it "Check if a card is in use" do
      oystercard.instance_variable_set(:@balance, Journey::MINIMUM_CHARGE)
      oystercard.touch_in(entry_station)
      expect{oystercard.touch_in(entry_station)}.to raise_error "Card already in use"
    end

    it "Changes in_journey status to true when touching in" do
      oystercard.instance_variable_set(:@balance, Journey::MINIMUM_CHARGE)
      expect(oystercard.touch_in(entry_station)).to_not eq nil
    end

    it "Raises an error if card is already in use" do
      oystercard.instance_variable_set(:@balance, Journey::MINIMUM_CHARGE)
      oystercard.touch_in(entry_station)
      expect{oystercard.touch_in(entry_station)}.to raise_error "Card already in use"
    end

    it "Expects the card to remember the station departed from" do
      oystercard.instance_variable_set(:@balance, Journey::MINIMUM_CHARGE)
      expect(oystercard.touch_in(entry_station)).to eq entry_station
    end

    it "Doesn't allow access when there is not enough credit" do
      expect{oystercard.touch_in(entry_station)}.to raise_error "Not enough credit"
    end
  end

  describe "#touch_out(exit_station)" do
    it "Changes injourney status to false when touching out" do
      oystercard.top_up(50)
      oystercard.touch_in(entry_station)
      oystercard.touch_out(exit_station)
      expect(oystercard.injourney).to eq false
    end

    it "Raises an error if card is not in use" do
      oystercard.top_up(50)
      expect{oystercard.touch_out(exit_station)}.to raise_error "Card not in use"
    end

    it "Deducts correct fare for the journey" do
      oystercard.top_up(50)
      oystercard.touch_in(entry_station)
      expect{oystercard.touch_out(exit_station)}.to change{oystercard.balance}.by(-Journey::MINIMUM_CHARGE)
    end
  end

end
