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
        @authors = Nesta::Config.authors
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
        @authors.each do |a|
          if a[ "name" ].to_s.downcase == author.downcase
            return a[ key ]
          end
        end
      end
    end
   
    # Add new routes here.
  end
  
  class Config
    def self.authors
      authors = from_yaml("authors")
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
