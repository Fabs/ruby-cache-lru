require 'rspec'
require 'lru'

describe Lru do
  before :each do
    @lru = Lru.new
  end
  describe 'basic cache' do
    it 'remember cached items' do
      optional = @lru.retrieve('index.html')

      expect(@lru.size).to eq(1)
      expect(optional.missed?).to eq(true)
    end

    it 'caches items only once' do
      @lru.retrieve('index.html')
      optional = @lru.retrieve('index.html')

      expect(@lru.size).to eq(1)
      expect(optional.missed?).to eq(false)
    end

    it 'has a max default size og 5' do
      20.times{ | i | @lru.retrieve("page#{i}.html")}
      expect(@lru.size).to eq(10)
    end
  end

  describe 'LRU strategy' do
    it 'caches items only to a maximum' do
      # the 10 first gets into, the eleventh gets the page0 out of cache
      11.times{ | i | @lru.retrieve("page#{i}.html")}

      expect(@lru.size).to eq(10)

      #Searching page 0 is a miss, because it got deleted from cache
      optional = @lru.retrieve("page0.html")
      expect(optional.missed?).to eq(true)
    end

    it 'updates the least accessed' do
      #Fits perfectly 10 items on cache
      10.times{ | i | @lru.retrieve("page#{i}.html")}

      expect(@lru.size).to eq(10)

      #Reads the 0, so its not the oldest anymore
      @lru.retrieve("page0.html")

      #Reads something not on cache, will inalidate an old one, and store the 45
      @lru.retrieve("page45.html")

      expect(@lru.size).to eq(10)

      #Asking for the 0, won't be a miss
      optional = @lru.retrieve("page0.html")
      expect(optional.missed?).to eq(false)
    end
  end
end