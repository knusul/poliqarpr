#vim:encoding=utf-8
require File.join(File.dirname(__FILE__), '..','lib','poliqarpr')

describe Poliqarp::Client do
  describe "(general test)" do
    before(:each) do
      @client = Poliqarp::Client.new("TEST")
    end
    
    after(:each) do 
      @client.close
    end
  
    it "should allow to open corpus" do
      @client.open_corpus("I:/Poliqarp/2.sample.30/sample")
    end
  
    it "should allow to open :default corpus" do
      @client.open_corpus(:default)
    end

    it "should respond to :ping" do
      @client.ping.should == :pong
    end

    it "should return server version" do
      @client.version.should_not == nil
    end

  end

  describe "(with 'sample' corpus)" do
    before(:all) do
      @client = Poliqarp::Client.new("TEST")
      @client.open_corpus(:default)
    end

    after(:all) do
      @client.close
    end

    it "should allow to set the right context size" do 
      @client.right_context = 5
    end

    it "should raise error if the size of right context is not number" do 
      (proc do 
        @client.right_context = "a"
      end).should raise_error(RuntimeError)
    end

    it "should rais error if the size of right context is less or equal 0" do 
      (proc do 
        @client.right_context = 0
      end).should raise_error(RuntimeError)
    end

    it "should allow to set the left context size" do 
      @client.right_context = 5
    end

    it "should raise error if the size of left context is not number" do 
      (lambda do 
        @client.left_context = "a"
      end).should raise_error(RuntimeError)
    end

    it "should rais error if the size of left context is less or equal 0" do 
      (lambda do 
        @client.left_context = 0
      end).should raise_error(RuntimeError)
    end

    it "should return corpus statistics" do
      stats = @client.stats
      stats.size.should == 4
      [:segment_tokens, :segment_types, :lemmata, :tags].each do |type|
        stats[type].should_not == nil
        stats[type].should > 0
      end
    end

    it "should return the corpus tagset" do
      tagset = @client.tagset
      tagset[:categories].should_not == nil
      tagset[:classes].should_not == nil
    end

    it "should allow to find 'kot'" do 
      @client.find("kot").size.should_not == 0
    end

    it "should contain 'kot' in query result for [base=kot]" do
      @client.find("[base=kot]")[0].to_s.should match(/\bkot\b/)
    end

    it "should allow to find 'jak [] nie" do
      @client.find("jak [] nie").size.should_not == 0
    end

    it "should contain 'jak [] nie" do
      @client.find("jak [] nie")[0].to_s.should match(/jak .* nie/)
    end

    it "should allow to find sets of chars" do
      @client.find('"kot[au]"').size.should == 6
    end

    it "should allow to find sets of chars2" do
      @client.find('[pos=subst]{6,} within s meta author=Kowalski').size.should_not == nil
    end

    it "should return collection for find without index specified" do
      @client.find("kot").should respond_to(:[])
    end

    it "should allow to query for term occurences" do
      @client.count("kot").should_not == nil
    end

    it "should return occurences for 'kot'" do
      @client.count("kot").should_not == 0
    end

    it "should allow to find first occurence of 'kot'" do
      @client.find("kot",:index => 0).should_not == nil
    end

    it "should return different results for different queries" do
      @client.find("kot").should_not ==
        @client.find("kita")
    end

    it "should return same results for same queries" do
      @client.find("kita").should == @client.find("kita")
    end

    it "should print description of the last error" do
      (proc do
        @client.find("ko[ta]")
      end).should raise_error(RuntimeError)
      @client.last_error.to_str.include?(']').should == true
    end

    it "should suspended and resume session" do
      @client.suspend_session
      @client.resume_session
      @client.find("kota").should_not raise_error(RuntimeError)
    end

    it "should return state of the buffer" do
       @client.buffer_state[0..8].eql?("OK 500000").should == true
    end

    it "should resize buffer" do
      @client.buffer_resize(550000)
      @client.buffer_state.split[1].eql?("550000").should == true
    end

    it "should get metadata" do
      @client.metadata("zestaw", "0").to_s.split("/")[-1].eql?("1965").should == true
    end

    it "should allow to set notification interval" do
      @client.notification_interval = 100
    end

    it "should allow to set disambiguity" do
      @client.disamb = 1
    end

    it "should define and delete alias" do
       aliases_number = @client.get_aliases.size
       @client.create_alias('alias', 'm1|m2')
       aliases_number.should == @client.get_aliases.size - 1
       @client.delete_alias('alias')
       aliases_number.should == @client.get_aliases.size
    end

    it "should sort results" do
       res = @client.find("kota")
       res[0].to_s.should match(/^,/)
       res[-1].to_s.should_not match(/^,/)
       res = @client.find("kota",  {:sorting => Poliqarp::SortingCriteria::A_TERGO_LEFT_CONTEXT})
       res[0].to_s.should_not match(/^,/)
       res[-1].to_s.should match(/^,/)
    end

    it "should get column types" do
      @client.column_types.should match(/([A-Z]+<>:)*[A-Z]+<>$/)
    end

    describe("(with index specified in find)") do
      before(:each) do 
        @result = @client.find("marny", :index => 1)
      end

      it "should not return collection for find" do
        @result.should_not respond_to(:[])
      end

      it "should not be nil" do
        @result.should_not == nil
      end

    end

    describe("(with lemmata flags set to true)") do 
      before(:all) do
        @client.lemmata = {:left_context => true, :right_context => true,
          :left_match => true, :right_match => true}
      end

      it "should allow to find 'kotu'" do 
        @client.find("kotu").size.should_not == 0
      end

      it "should contain 'kotu' in query result for 'kotu'" do
        @client.find("kotu")[0].to_s.should match(/\bkotu\b/)
      end

      it "should contain 'kot' in lemmatized query result for 'kotu'" do
        @client.find("kotu")[0].short_context.flatten.
          map{|e| e.lemmata[0].base_form}.join(" ").should match(/\bkot\b/)
      end

    end
  end

end
