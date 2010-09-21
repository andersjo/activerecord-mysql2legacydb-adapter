require File.expand_path(File.dirname(__FILE__) + '/spec_helper')



describe ActiveRecord::Base do
  context "'mysql2' adapter" do
    before do
      ActiveRecord::Base.establish_connection(TEST_CONFIG.merge({:adapter => 'mysql2'}))
    end

    it "should return a normal db connection" do
      ActiveRecord::Base.connection.should be_an_instance_of(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
    end
  end

  context "'mysql2legacydb' adapter" do
    before do
      ActiveRecord::Base.establish_connection(TEST_CONFIG.merge({:adapter => 'mysql2legacydb'}))
    end

    it "should return a legacy db connection" do
      ActiveRecord::Base.connection.should be_an_instance_of(ActiveRecord::ConnectionAdapters::Mysql2LegacyDBAdapter)
    end

  end
end

describe "ActiveRecord::ConnectionAdapters::Mysql2LegacyDBAdapter" do
  context "using connection" do
    it "returns altered table names" do
      conn = River.connection
      conn.stub!(:execute).and_return [["WildRivers"]]
      conn.tables.first.should == "wild_rivers"
    end
  end

  context "in ActiveRecord class" do
    before do
      VeryLongRiver.establish_connection(TEST_CONFIG.merge({:adapter => 'mysql2legacydb'}))
      River.establish_connection(TEST_CONFIG.merge({:adapter => 'mysql2legacydb'}))
    end

    it "should have altered column names" do
      River.column_names.should == ["name", "total_length_in_km", "total_length_in_miles"]
    end

    it "should have altered table names" do
      River.table_name.should == "rivers"
      VeryLongRiver.table_name.should == "very_long_rivers"
    end

  end

  context "in ActiveRecord instance" do
    before do
      @nile = River.where(:name => "Nile").first
    end

    it "should map altered column names" do
      @nile.total_length_in_miles.should == 4132
    end

  end
end

TEST_CONFIG = {
  :host     => "localhost",
  :username => "root",
  :password => "",
  :database => "test"
}
class River < ActiveRecord::Base; end
class VeryLongRiver < ActiveRecord::Base; end