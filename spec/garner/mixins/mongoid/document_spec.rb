require "spec_helper"
require "garner/mixins/mongoid"

describe Garner::Mixins::Mongoid::Document do
  context "at the class level" do
    subject { Monger }

    describe "_latest_by_updated_at" do
      it "returns a Mongoid::Document instance" do
        subject.create
        subject.send(:_latest_by_updated_at).should be_a(subject)
      end

      it "returns the _latest_by_updated_at document by :updated_at" do
        mongers = 3.times.map { subject.create }
        mongers[1].touch

        subject.send(:_latest_by_updated_at)._id.should == mongers[1]._id
        subject.send(:_latest_by_updated_at).updated_at.should == mongers[1].reload.updated_at
      end

      it "returns nil if there are no documents" do
        subject.send(:_latest_by_updated_at).should be_nil
      end

      it "returns nil if updated_at does not exist" do
        monger = subject.create
        subject.stub(:fields) { {} }
        subject.send(:_latest_by_updated_at).should be_nil
      end
    end

    describe "touch" do
      it "touches the _latest_by_updated_at document" do
        monger = subject.create
        subject.any_instance.should_receive(:touch)
        subject.touch
      end
    end

    describe "cache_key" do
      it "return's the _latest_by_updated_at document's cache key" do
        monger = subject.create
        subject.any_instance.should_receive(:cache_key)
        subject.cache_key
      end

      it "matches what would be returned from the full object" do
        monger = subject.create
        subject.cache_key.should == monger.reload.cache_key
      end

      context "with Mongoid subclasses" do
        subject { Cheese }

        it "matches what would be returned from the full object" do
          cheese = subject.create
          subject.cache_key.should == cheese.reload.cache_key
        end
      end
    end
  end
end
