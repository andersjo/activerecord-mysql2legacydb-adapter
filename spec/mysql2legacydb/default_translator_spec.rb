require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mysql2legacydb::DefaultTranslator do
    EXAMPLE_MAPPINGS = {
      'veryLongRivers' => 'very_long_rivers',
      'rivers' => 'rivers'
    }

  before {
    @translator = Mysql2legacydb::DefaultTranslator.new
  }

  describe "legacy_to_new" do
    it "should underscore input" do
      EXAMPLE_MAPPINGS.each do |legacy,new|
        @translator.legacy_to_new(legacy).should == new
      end
    end

    it "should be reversible" do
      EXAMPLE_MAPPINGS.each do |legacy,new|
        translated_new = @translator.legacy_to_new(legacy)
        @translator.new_to_legacy(translated_new).should == legacy
      end
    end
  end

  describe "new_to_legacy" do
    it "should camelcase underscores" do
      EXAMPLE_MAPPINGS.each do |legacy,new|
        @translator.new_to_legacy(new).should == legacy
      end
    end

    it "should be reversible" do
      EXAMPLE_MAPPINGS.each do |legacy,new|
        translated_legacy = @translator.new_to_legacy(new)
        @translator.legacy_to_new(translated_legacy).should == new
      end
    end
  end

end