module FusionRing
  require 'csv'

    class FusionRingGenerator < Jekyll::Generator
        safe true
        
        def generate(site)

          site.static_files.each do |file|
            filename=file.name
            if file.name.match? /FR_[^_]+_[^_]+_[^_]+_[^\.]+.csv/
              site.pages << FusionRingPage.new(site, file.basename, file.path)
            end
          end           
        end

    end

    class FusionRingPage < Jekyll::Page

      def initialize(site, title, path)

        @site = site             # the current site instance.
        @base = site.source      # path to the source directory.
        @dir  = "FusonRings"         # the directory the page will reside in.

        # All pages have the same filename, so define attributes straight away.
        @basename = title      # filename without the extension.
        @ext      = '.html'      # the extension.
        @name     = title+@ext # basically @basename + @ext.

        @layout = "FusionRing"
        @title = title

        fusiondata = CSV.parse(File.read(path), headers: true, converters: :numeric)

        obs = fusiondata['a'].uniq
      
        fusiontable = Hash.new
        for a in obs
          fusiontable[a] = Hash.new
          for b in obs
            fusiontable[a][b] = Hash.new
            for c in obs
              fusiontable[a][b][c] = 0

              nabc = fusiondata.find {|row| row['a'] == a && row['b'] == b && row['c'] == c}
              if nabc
                fusiontable[a][b][c] = nabc['n']
              end

            end
            
          end
        end

        fr_data = basename.split('_')
        r = fr_data[1]
        m = fr_data[2]
        n = fr_data[3]
        i = fr_data[4]

        puts fr_data

        if m == '1'
          displayname = '\(\text{FR}^{'+r+n+'}_{'+i+'}\)'
        else
          displayname = '\(\text{FR}^{'+r+m+n+'}_{'+i+'}\)'
        end
        
        puts displayname

        @template = ':path'
        @data = {
          'layout' => "fusionring", 
          'permalink' => '/FusionRings/'+basename+'.html', 
          'tag' => 'FusionRing', 
          'title' => title, 
          'obs'=> obs, 
          'displayname' => displayname,
          'r' => r, 
          'm' => m, 
          'n' => n, 
          'i' => i, 
          'fusiontable' => fusiontable 
          }
               
      end

    end

    def url_placeholders
      {
        :path       => @dir,
        :category   => "FusionRing",
        :basename   => basename,
        :output_ext => output_ext,
      }
    end
      
  end