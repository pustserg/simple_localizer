require 'sinatra/base'
require 'sinatra/reloader'
require 'yaml'

require './models/locale'

class App < Sinatra::Base
  CURRENT_LOCALE_FILENAME = 'current_locale.bin'.freeze
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    slim :index, layout: true
  end

  post '/upload' do
    locale = Locale.parse(YAML.load(params[:locale_file][:tempfile]))
    dump_locale(locale)
    redirect to('/edit')
  end

  get '/edit' do
    locale = load_locale
    if locale
      slim :edit, layout: true, locals: { locale: locale }
    else
      redirect to('/')
    end
  end

  post '/update' do
    locale = load_locale
    if locale
      locale.change_node_value(params[:parent_key], params[:new_val])
      dump_locale(locale)
      redirect to('/edit')
    else
      redirect to('/')
    end
  end

  get '/download' do
    locale = load_locale
    if locale
      File.open('out.yml', 'w') do |outfile|
        outfile.write(locale.to_hash.to_yaml)
      end
      send_file 'out.yml', type: :yml, disposition: :attachment, filename: "#{locale.language}.yml"
    else
      redirect to('/')
    end
  end

  def dump_locale(locale)
    File.open(CURRENT_LOCALE_FILENAME, 'wb') do |f|
      f.write(Marshal.dump(locale))
    end
  end

  def load_locale
    return false unless File.exists?(CURRENT_LOCALE_FILENAME)

    Marshal.load(File.read(CURRENT_LOCALE_FILENAME))
  end

  run! if app_file == $0
end
