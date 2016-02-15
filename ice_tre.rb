require 'sinatra'
require 'json'
require 'pp' # for pretty debugging output
require 'mini_magick'
require 'pry'

helpers do
  def valid_hex_color?(color)
    match = color.match(/^#([0-9a-fA-F]{6}){1,2}$/)

    match.to_s.length > 0
  end

  def assign_image(file_name)
    image_file = "images/#{file_name}.png"

    if File.file?(image_file)
      MiniMagick::Image.open(image_file)
    else
      MiniMagick::Image.open("images/#{random_image_name}.png")
    end
  end

  def assign_width(width)
    assign_dimension(width,1024)
  end

  def assign_height(height)
    assign_dimension(height,768)
  end
  
  def assign_dimension(dimension, default)
    sanitized = dimension.to_i

    if sanitized > 0
      [[2560, sanitized].min, 16].max
    else
      default
    end
  end

  def assign_color(color)
    if valid_hex_color?("##{color}")
      "##{color}"
    else
      '#ffffff'
    end
  end

  def assign_percent(percent)
    sanitized = percent.to_i

    if sanitized > 0
      [[300, sanitized].min, 10].max
    else
      100
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
    file_paths = Dir['images/*']
    file_paths.each { |file_path| file_path.gsub!('images/', '').gsub!('.png', '') }
  end

  def random_image_name
    image_file_names.sample
  end

  def options_for_image_select
    select_hash = {}

    image_file_names.each do |file|
      select_hash[file] = file.split('_').map { |name| name.capitalize }.join(' ')
    end

    select_hash
  end

  def response_image(image_name, width, height, color, percent)
    image   = assign_image("#{image_name}")
    width   = assign_width("#{width}")
    height  = assign_height("#{height}")
    color   = assign_color("#{color}")
    percent = assign_percent("#{percent}")

    format_image(image, width, height, color, percent)
    content_type 'image/jpg'
    image.to_blob
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

post '/images' do
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

  response_image(nil, width, height,hex_color, percent)

end

get /^\/(\d+)\/(\d+)\/([a-fA-F0-9]{6}){1,2}\b\/*/ do |width, height, hex_color|

  response_image(nil, width, height, hex_color, nil)

end

get /^\/(\d+)\/(\d+)\/*/ do |width, height|

  response_image(nil, width, height, nil, nil)

end

get '/?:image?/?:width?/?:height?/?:color?/?:percent?/?' do

  response_image(params[:image], params[:width], params[:height], params[:color], params[:percent])

end

# route methods for undefined API requests

not_found do
  error 400
end

error 401 do
  "{'error':'unauthorized', 'message':'You are not authorized to access this resource.'}"
end