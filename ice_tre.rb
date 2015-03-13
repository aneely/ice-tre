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

  def format_image(image, width, height, color)
    puts 'inside format_image'
    image.combine_options do |img|
      img.thumbnail("#{width}x#{height}>")
      img.background(color)
      img.gravity('South')
      img.extent("#{width}x#{height}")
    end
  end
end

get '/help/?' do
  status 200
  help_string = '<html><body>' +
                '<p>The URL parameters are constructed as /rapper/width/height/color/percent/</p>' +
                '<p> - the options for rapper are ice_cube, ice_t, and vanilla_ice</p>' +
                '<p> - the options for width and height include any valid positive integer below 2560</p>' +
                '<p> - the options for color include any valid hex web color without the pound sign in front of it</p>' +
                '<p> - the options for percent include any positive integers up to 300</p>' +
                '<p>An example of a valid URL is /vanilla_ice/1024/768/ffffff/</p>' +
                '<p>Note: the trailing slash is optional</p>' +
                '</html></body>'
  return help_string
end

get '/?:rapper?/?:width?/?:height?/?:color?/?:percent?/?' do
  image   = assign_rapper_image("#{params[:rapper]}", 'vanilla_ice')
  width   = assign_dimension("#{params[:width]}", 1024)
  height  = assign_dimension("#{params[:height]}", 768)
  color   = assign_color("#{params[:color]}", 'ffffff')
  percent = assign_percent("#{params[:percent]}")

  if image and valid_width_and_height?(height, width) and valid_hex_color?(color)
    format_image(image, width, height, color)
    content_type 'image/jpg'
    image.sample("#{percent}%") if percent
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