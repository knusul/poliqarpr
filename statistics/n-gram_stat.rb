require 'lib/poliqarpr'

describe Poliqarp::Client do
  describe "n-gram statistics" do
    before(:each) do
      @client = Poliqarp::Client.new("TEST")
    end
    
    after(:each) do 
      @client.close
    end
  
    it "should print sample 2-grams statistics" do
	@client.open_corpus("C:/dev/2.sample.30/sample")
	["kota ma", "po to","taki jak","kto to","oby nie" ].each{|form |
	puts "Form \"#{form}\" appears #{@client.find(form).size} times"
	}
    end
    it "should print sample interwords connections" do
	@client.open_corpus(:default)
	["poszedł em","bronił am", "pokonał em"].each{|form |
	puts "Form \"#{form}\" appears #{@client.find(form).size} times"
	
	}
    end
  end
end