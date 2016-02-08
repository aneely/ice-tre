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

  def assign_rapper_image(rapper, default)
    image_file = "image/#{rapper}.png"

    if File.file?(image_file)
      MiniMagick::Image.open(image_file)
    else
      MiniMagick::Image.open("image/#{default}.png")
    end
  end

  def assign_dimension(value, default)
    sanitized_dimension = value.to_i
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
end

get '/help/?' do
  erb :help
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

get '/?:rapper?/?:width?/?:height?/?:color?/?:percent?/?' do
  image   = assign_rapper_image("#{params[:rapper]}", 'vanilla_ice')
  width   = assign_dimension("#{params[:width]}", 1024)
  height  = assign_dimension("#{params[:height]}", 768)
  color   = assign_color("#{params[:color]}", 'ffffff')
  percent = assign_percent("#{params[:percent]}") || 100

  if image and valid_width_and_height?(height, width) and valid_hex_color?(color)
    format_image(image, width, height, color, percent)
    content_type 'image/jpg'

    image.to_blob
  else
    redirect('/vanilla_ice/1024/768/ffffff/')
  end
end

# route methods for undefined API requests

not_found do
  error 400
end

error 401 do
  "{'error':'unauthorized', 'message':'You are not authorized to access this resource.'}"
end