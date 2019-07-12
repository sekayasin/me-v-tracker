require "rails_helper"

RSpec.describe RedisService, type: :service do
  context "when redis is available", :redis do
    before(:each) do
      RedisService.set("key1", "value1")
    end

    it "sets a value to a key" do
      expect(RedisService.set("key2", "value2")).to eq(true)
      expect(RedisService.set("key3", [1, 2, 3, 4, 5])).to eq(true)
      expect(RedisService.set("key4", nil)).to eq(false)
      expect(RedisService.set("key5", [])).to eq(false)
      expect(RedisService.set("key6", {})).to eq(false)
    end

    it "gets a value by key" do
      expect(RedisService.get("key1")).to eq("value1")
    end

    it "checks if a key exists" do
      expect(RedisService.get("key4")).to eq(false)
      expect(RedisService.get("key5")).to eq(false)
      expect(RedisService.get("key6")).to eq(false)
    end

    it "deletes a single key" do
      expect(RedisService.delete_key("key1")).to eq(1)
      expect(RedisService.delete_key("key77")).to eq(0)
    end

    it "deletes all keys" do
      expect(RedisService.delete_all_keys).to eq("OK")
    end
  end

  context "when redis is unavailable", :redis do
    before(:each) do
      allow(RedisService).to receive(:redis_disconnected?).and_return(true)
    end

    it "it fails to get" do
      expect(RedisService.get("key1")).to eq false
    end

    it "it fails to set" do
      expect(RedisService.set("key1", "value1")).to eq false
    end
  end
end
