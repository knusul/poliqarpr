require File.join(File.dirname(__FILE__), '..','lib','poliqarp')

describe Poliqarp::Client do
  describe "(general test)" do
    before(:each) do
      @client = Poliqarp::Client.new("TEST")
    end
    
    after(:each) do 
      @client.close
    end
  
    it "should allow to open corpus" do
      @client.open_corpus("/home/fox/local/poliqarp/2.sample.30/sample")
    end
  
    it "should allow to open :default corpus" do
      @client.open_corpus(:default)
    end
  end

  describe "(with 'sample' corpus)" do
    before(:all) do
      @client = Poliqarp::Client.new("TEST")
      @client.open_corpus("/home/fox/local/poliqarp/2.sample.30/sample")
    end

    after(:all) do
      @client.close
    end

    it "should allow to find 'kot'" do 
      @client.find("kot").size.should_not == 0
    end

    it "should contain 'kot' in query result for [base=kot]" do
      @client.find("[base=kot]")[0].to_s.should match(/\bkot\b/)
    end

    it "should allow to find 'Afrodyta [] od" do
      @client.find("Afrodyta [] od").size.should_not == 0
    end

    it "should contain 'Afrodyta .* od' for 'Afrodyta [] od' query " do
      @client.find("Afrodyta [] od")[0].to_s.should match(/Afrodyta .* od/)
    end

    it "should return collection for find without index specified" do
      @client.find("kot").should respond_to(:[])
    end

    it "should allow to query for term occurences" do
      @client.count("kot").should_not == nil
    end

    it "should return 188 occurences of 'kot'" do
      @client.count("kot").should == 188
    end

    it "should allow to find first occurence of 'kot'" do
      @client.find("kot",:index => 0).should_not == nil
    end

    describe("(with index specified in find)") do
      before(:each) do 
        @result = @client.find("nachalny",:index => 0)
      end

      it "should not return collection for find" do
        @result.should_not respond_to(:[])
      end

      it "should fetch the same excerpt as in find without index " do
        @result.to_s.should == @client.find("nachalny")[0].to_s
      end
    end
  end

end
