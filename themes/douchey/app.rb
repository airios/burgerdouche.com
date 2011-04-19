# Use the app.rb file to load Ruby code, modify or extend the models, or
# do whatever else you fancy when the theme is loaded.

require 'rubygems'
require 'compass' #must be loaded before sinatra
require 'sinatra'
require 'haml' #must be loaded after sinatra

module Nesta
  
  class App
    # Uncomment the Rack::Static line below if your theme has assets
    # (i.e images or JavaScript).
    #
    # Put your assets in themes/douchey/public/douchey.
    #
    use Rack::Static, :urls => ["/douchey"], :root => "themes/douchey/public"
        
    configure do
            
      Compass.configuration do |config|
        config.project_path = File.dirname(__FILE__)
        config.sass_dir = 'views'
        config.environment = :production
        config.relative_assets = true
        config.http_path = "/"
        config.http_images_path = "../douchey/images"
        config.images_dir = "../douchey/images"
      end

      set :haml, { :format => :html5 }
      set :sass, Compass.sass_engine_options
    end

    get '/css/:sheet.css' do
      content_type 'text/css', :charset => 'utf-8'
      cache sass(params[:sheet].to_sym)
    end

    helpers do
      # Add new helpers here.
      def set_common_variables
        @menu_items = Nesta::Menu.for_path('/')
        @site_title = Nesta::Config.title
        @default_author = Nesta::Config.author
        @authors = Nesta::Config.authors
        @search_api_key = Nesta::Config.google_search_api_key
        set_from_config(:title, :subtitle, :google_analytics_code)
        @heading = @title
      end
      
      def author_uri(author)
        get_author_data_by_key(author,"uri")
      end
      
      def author_adsense_id(author)
        get_author_data_by_key(author,"adsenseid")
      end
      
      def author_email(author)
        get_author_data_by_key(author,"email")
      end
      
      def get_author_data_by_key(author,key)
        item = String.new
        @authors.each do |a|
          if a[ "name" ].to_s.downcase == author.downcase
            item = a[ key ]
          end
        end
        if item.empty?
          item = @default_author[ key ]
        end
        item
      end
      
      def get_article_categories
        @article_categories = @page.find_articles_with_categories
      end
      
      def get_archived_content
        @archived_pages = @page.find_archived_content
      end
      
      def format_date(date)
        date.strftime('%B %d, %Y')
      end
      
      def format_month( month )
        m = Date::MONTHNAMES[ month ]
      end
      
      def get_star_ratings
        rating = @page.rating.to_f
        rating = 0 if rating.nil?
        
        ratings = []
        
        if rating < 0 && rating > 5
          rating = 0
        end
        
        if rating > 5
          rating = 5
        end

        # The base tag
        # tag = "<img src=\"#{base_url}/images/ratings/%s\"  alt=\"%s\" />"

        # htmlstr = String.new

        # Get the rating difference to use against calculations
        diff = ( '%.1f' % ( rating.to_f - rating.to_i ) ).to_f

        # Be sure to catch all instances of the rating
        if ( 0.1..0.5 ).include?( diff )
          diff = 0.5
        elsif ( 0.6..0.9 ).include?( diff )
          diff = diff.round
        end

        ( 0..4 ).each do |i|
          if i + diff < rating
            # htmlstr << tag % [ "star-filled.png", rating.to_s + "/5"  ]
            ratings.push "star-filled.png"
          elsif diff == 0.5 && i + diff == rating
            # htmlstr << tag % [ "star-half-filled.png", rating.to_s + "/5" ]
            ratings.push "star-half-filled.png"
          else
            # htmlstr << tag % [ "star-empty.png", rating.to_s + "/5" ]
            ratings.push "star-empty.png"
          end
        end
        
        # htmlstr
        ratings    
      end
      
    end
   
    # Add new routes here.
  end
  
  class Config
    def self.authors
      authors = from_yaml("authors")
    end
    
    def self.google_search_api_key
      from_yaml("google_search_api_key")
    end
    
    def self.article_path(basename = nil)
      get_path(File.join(page_path, "articles"), basename)
    end
    
  end
  
  class Page
    def find_articles_with_categories
       items = []
       all = Page.find_articles.select{ |a| !a.categories.empty? }.each do |x|
         x.categories.each do |i|
           items.push i
         end
       end
       items
    end
        
    def find_archived_content
      coll = {}
      Page.find_articles.reverse.each do |article|
        year, month, day = article.date.year, article.date.month, article.date.day
        
        unless coll.key? year
          coll[ year ] = {}
        end
        
        unless coll[ year ].key? month
          coll[ year ][ month ] = {}
        end
        
        unless coll[ year ][ month ].key? day
          coll[ year ][ month ][ day ] = []
        end
        
        coll[ year ][ month ][ day ] += [ article ]
      end
      coll
    end
    
    def rating
      metadata("rating")
    end
  end
  
  class FileModel
    def author
      if metadata("author")
        metadata("author")
      else
        Nesta::Config.author["name"]
      end
    end
  end
end
