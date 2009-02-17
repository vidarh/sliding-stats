require 'SVG/Graph/BarHorizontal'
require 'rack'

module SlidingStats

  # Provides a basic view of the stats. You can easily provide a custom
  # view by subclassing and overriding the #show method, or replacing it
  # completely.
  class View
    def show(data)
      r = Rack::Response.new
      r.write("<html><head><title>Sliding Stats</title><style>h2 {margin-top: 20px;}</style> <body>")
      r.write("<h1>Sliding Stats</h1>")
      # Setting the size here is a *hack*. Need to fix that
      r.write("<h2>Most recent referrers</h2>")
      r.write("<div style='width: 1000px;'><embed pluginspage=\"http://www.adobe.com/svg/viewer/install/\" type=\"image/svg+xml\" src=\"#{data[:base]}/referers.svg\" style=\"margin-left: 50px; width: 1000px; height: #{40 + 20*data[:referers].size}px;\"></div>")
      r.write("<h2>Most recent pages</h2>")
      r.write("<div style='width: 1000px;'><embed pluginspage=\"http://www.adobe.com/svg/viewer/install/\" type=\"image/svg+xml\" src=\"#{data[:base]}/pages.svg\" style=\"margin-left: 50px; width: 1000px; height: #{40 + 20*data[:pages].size}px;\"></div>")
      r.write("<h2>Most recent referrers broken down by pages</h2>")
      r.write("<table border='1' style=\"display:inline; margin-top: 20px; margin-left: 100px; width: 950px; \"><tr><th>Referer</th><th>Pages</th></tr>\n")
      data[:referers_to_pages].each do |k,v|
        r.write("<tr><td>#{CGI.escapeHTML(k)}</td> <td><table>")
        total = v[:total]
        if v.size > 2 # include :total
          r.write("<tr><td>#{total}</td><td><strong>total</strong></td></tr>")
        end
        v.sort_by{|page,count| -count}.each do |page,count| 
          r.write("<tr><td>#{count}</td><td>#{page.to_s}</td></tr>") if page != :total
        end
        r.write("</table></td></tr>\n")
      end
      r.write("</table>")
      r.write("<div style='margin-top: 50px'>Stats by <a href='http://www.hokstad.com/slidingstats'>Sliding Stats</a> -- Copyright 2009 <a href='http://www.hokstad.com/'>Vidar Hokstad</a>. </div>")
      r.write("</body></html>")
      r.finish
    end

    def show_svg(src)
      fields = []
      data = []
      src.each do |k,v|
        if k != "-" # Excluding because of referers
          k = k[0..79] + "..." if k.length > 80
          fields << CGI.escapeHTML(k)
          data   << v
        end
      end

      if fields.empty?
        r = Rack::Response.new("No data")
        return r.finish
      end

      graph = SVG::Graph::BarHorizontal.new(
                                            :height => 40 + 20 * data.size,
                                            :width => 1000,
                                            :fields => fields.reverse
                                            )
      graph.add_data(:data => data.reverse)
      graph.rotate_y_labels = false
      graph.scale_integers = true
      graph.key = false
      r = Rack::Response.new
      r["Content-Type"] = "image/svg+xml"
      r.write(graph.burn)
      r.finish
    end
  end
end
