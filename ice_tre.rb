require 'sinatra'
require 'json'
require 'pp' # for pretty debugging output
require 'mini_magick'
require 'pry'

helpers do
  def valid_width_and_height?(width, height)
    width > 0 && height > 0
  end

  def valid_dimension?(value)
    value > 0
  end

  def valid_hex_color?(color)
    match = color.match(/^#([0-9a-fA-F]{3}){1,2}$/)
    match.to_s.length > 0
  end

  def valid_non_zero_percentage?(percentage)
    percentage > 0
  end

  def assign_image(file_name, default)
    image_file = "image/#{file_name}.png"

    if File.file?(image_file)
      MiniMagick::Image.open(image_file)
    else
      MiniMagick::Image.open("image/#{default}.png")
    end
  end

  def assign_dimension(dimension, default)
    sanitized_dimension = dimension.to_i

    if valid_dimension?(sanitized_dimension)
      sanitized_dimension
    else
      default
    end
  end

  def assign_color(color, default)
    if valid_hex_color?("##{color}")
      "##{color}"
    else
      "##{default}"
    end
  end

  def assign_percent(percent)
    if valid_non_zero_percentage?(percent.to_i)
      percent.to_i
    else
      false
    end
  end

  def dimension_for_percent(dimension, percent)
    if percent == 100
      dimension
    else
      (dimension * (percent / 100.0)).to_i
    end
  end

  def format_image(image, width, height, color, percent)
    width = dimension_for_percent(width, percent)
    height = dimension_for_percent(height, percent)

    image.combine_options do |img|
      img.thumbnail("#{width}x#{height}>")
      img.background(color)
      img.gravity('South')
      img.extent("#{width}x#{height}")
    end

    image.format('jpg')
    image.quality(90)
  end

  def image_file_names
    file_paths = Dir['image/*']
    file_paths.each { |file_path| file_path.gsub!('image/', '').gsub!('.png', '') }
  end

  def options_for_image_select
    select_hash = {}

    image_file_names.each do |file|
      select_hash[file] = file.split('_').map { |name| name.capitalize }.join(' ')
    end

    select_hash
  end
end

# defined route methods

get '/' do
  @image_select_hash = options_for_image_select
  @example_image = {
      file: @image_select_hash.keys.last,
      name: @image_select_hash.values.last
  }

  erb :index
end

post '/image' do
  image   = params[:image_input]
  width   = params[:width_input]
  height  = params[:height_input]
  color   = params[:color_input]
  percent = params[:percent_input]

  unless color.nil?
    color.gsub!('#','').downcase!
  end

  redirect("/#{image}/#{width}/#{height}/#{color}/#{percent}/")
end

get /^\/(\d+)\/(\d+)\/([a-fA-F0-9]{6}){1,2}\b\/(\d+)\/*/ do |width, height, hex_color, percent|
  random_image_name = image_file_names.sample

  redirect("/#{random_image_name}/#{width}/#{height}/#{hex_color}/#{percent}/")
end

get /^\/(\d+)\/(\d+)\/([a-fA-F0-9]{6}){1,2}\b\/*/ do |width, height, hex_color|
  random_image_name = image_file_names.sample

  redirect("/#{random_image_name}/#{width}/#{height}/#{hex_color}/")
end

get /^\/(\d+)\/(\d+)\/*/ do |width, height|
  random_image_name = image_file_names.sample

  redirect("/#{random_image_name}/#{width}/#{height}/ffffff/")
end

get '/?:image?/?:width?/?:height?/?:color?/?:percent?/?' do
  random_image_name = image_file_names.sample

  image   = assign_image("#{params[:image]}", random_image_name)
  width   = assign_dimension("#{params[:width]}", 1024)
  height  = assign_dimension("#{params[:height]}", 768)
  color   = assign_color("#{params[:color]}", 'ffffff')
  percent = assign_percent("#{params[:percent]}") || 100

  format_image(image, width, height, color, percent)
  content_type 'image/jpg'
  image.to_blob
end

# route methods for undefined API requests

not_found do
  error 400
end

error 401 do
  "{'error':'unauthorized', 'message':'You are not authorized to access this resource.'}"
end