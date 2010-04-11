require 'lib/poliqarpr'

describe Poliqarp::Client do
  describe "n-gram statistics" do
    before(:each) do
      @client = Poliqarp::Client.new("TEST")
    end
    
    after(:each) do 
      @client.close
    end
  
    it "should return sample 2-grams statistics" do
      @client.open_corpus(:default)
	  @client.find("kota ma").each{| result| 
	  puts result 
	  }
	  @client.find("po to").each{| result| 
	  puts result 
	  }
    end
  end
end