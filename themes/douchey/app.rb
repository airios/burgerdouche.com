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
    # use Rack::Static, :urls => ["/douchey"], :root => "themes/douchey/public"
        
    configure do
      Compass.configuration do |config|
        config.project_path = File.dirname(__FILE__)
        config.sass_dir = 'views'
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
    end

    # Add new routes here.
  end
end
