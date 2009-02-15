
module SlidingStats

  # Calculates and maintains stats for a set of
  # requests. 
  class Stats
    attr_reader :referers, :pages, :referers_to_pages
    def initialize request,ex_referers,ex_pages
      @exclude_referers = ex_referers || []
      @exclude_pages = ex_pages || []

      @referers = {}
      @pages = {}
      @referers_to_pages = {} # Two level

      request.each { |r| self.add(r) }
    end

    # Add a single line of stats data
    def add r
      ref = r["HTTP_REFERER"]
      req = r["REQUEST_URI"]

      ex_ref = @exclude_referers.detect{|pat| ref =~ pat}
      ex_req = @exclude_pages.detect{|pat| req =~ pat}

      if !ex_ref
        @referers[ref] ||= 0
        @referers[ref] += 1
      end

      if !ex_req
        @pages[req] ||= 0
        @pages[req] += 1
      end

      if !ex_ref && !ex_req
        @referers_to_pages[ref] ||= {:total => 0}
        @referers_to_pages[ref][req] ||= 0
        @referers_to_pages[ref][req] += 1
        @referers_to_pages[ref][:total] += 1
      end
    end

    def sub r
      ref = r["HTTP_REFERER"]
      req = r["REQUEST_URI"]

      ex_ref = @exclude_referers.detect{|pat| ref =~ pat}
      ex_req = @exclude_pages.detect{|pat| req =~ pat}

      if !ex_ref
        @referers[ref] -= 1 if @referers[ref]
      end

      if !ex_req
        @pages[req] -= 1 if @pages[ref]
      end

      if !ex_ref && !ex_req
        if @referers_to_pages[ref]
          @referers_to_pages[ref][req] -= 1 if @referers_to_pages[ref][req]
          @referers_to_pages[ref][:total] -= 1
        end
      end
    end
  end
end
