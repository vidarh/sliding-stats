

module SlidingStats
  
  # This class provides basic persistence for SlidingStats
  # To use it, simply add add :persist => [number of requests
  # between saves] to the SlidingStats::Window options,
  # or pass a different persistence class.
  class Persist
    def initialize every = 10,path="/var/tmp/slidingstats"
      @every = every
      @num = 0
      @path = path
    end

    def load
      begin
        Marshal.load(File.read(@path))
      rescue
        []
      end
    end

    def save requests
      @num += 1
      if (@num % @every) == 0
        File.open(@path,"w") do |f| 
          f.write(Marshal.dump(requests)) 
        end
      end
    end
  end
end
