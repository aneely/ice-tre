require 'sinatra'
require 'json'
require 'pp' # for pretty debugging output
require 'mini_magick'
require 'pry'

helpers do
  def valid_width_and_height?(height, width)
    width > 0 && height > 0
  end

  def valid_hex_color?(color)
    match = color.match(/^#([0-9a-fA-F]{3}){1,2}$/)
    match.to_s.length > 0
  end

  def assign_rapper_jpg(rapper)
    begin
      MiniMagick::Image.open("image/#{rapper}_white_bg.jpg")
    rescue
      false
    end
  end

  def assign_transparent_rapper_png(rapper)
    begin
      MiniMagick::Image.open("image/#{rapper}_transp.png")
    rescue
      false
    end
  end

  def resize_and_pad_with_color(image, width, height, color)
    image.combine_options do |img|
      img.thumbnail("#{width}x#{height}>")
      img.background(color)
      img.gravity('South')
      img.extent("#{width}x#{height}")
    end
  end
end

# trying to test if mini_magick is installed correctly
get '/vanilla_ice' do
  image = MiniMagick::Image.open('image/vanilla_ice_white_bg.jpg')
  content_type 'image/jpg'
  image.to_blob
end

get '/rapper/vanilla_ice/:percentage/percent' do
  percentage = "#{params[:percentage]}".to_i
  if percentage > 0
    image = MiniMagick::Image.open('image/vanilla_ice_white_bg.jpg')
    image.sample("#{percentage}%")
    content_type 'image/jpg'
    image.to_blob
  else
    redirect('/vanilla_ice')
  end
end

get '/rapper/vanilla_ice/width/:width/height/:height' do
  width = "#{params[:width]}".to_i
  height = "#{params[:height]}".to_i
  color = '#FFFFFF'

  if valid_width_and_height?(height, width)
    image = MiniMagick::Image.open('image/vanilla_ice_white_bg.jpg')
    image.combine_options do |img|
      img.thumbnail("#{width}x#{height}>")
      img.background(color)
      img.gravity('South')
      img.extent("#{width}x#{height}")
    end
    content_type 'image/jpg'
    image.to_blob
  else
    redirect('/vanilla_ice')
  end
end

get '/rapper/:rapper/width/:width/height/:height' do
  image = assign_rapper_jpg("#{params[:rapper]}")
  width = "#{params[:width]}".to_i
  height = "#{params[:height]}".to_i
  color = '#FFFFFF'

  if image and valid_width_and_height?(height, width)
    resize_and_pad_with_color(image, width, height, color)
    content_type 'image/jpg'
    image.to_blob
  else
    redirect('/vanilla_ice')
  end
end

get '/rapper/:rapper/w/:width/h/:height' do
  image = assign_rapper_jpg("#{params[:rapper]}")
  width = "#{params[:width]}".to_i
  height = "#{params[:height]}".to_i
  color = '#FFFFFF'

  if image and valid_width_and_height?(height, width)
    resize_and_pad_with_color(image, width, height, color)
    content_type 'image/jpg'
    image.to_blob
  else
    redirect('/vanilla_ice')
  end
end

get '/rapper/:rapper/width/:width/height/:height/background_color/:color' do
  image  =  assign_transparent_rapper_png("#{params[:rapper]}")
  width  =  "#{params[:width]}".to_i
  height =  "#{params[:height]}".to_i
  color  = "##{params[:color]}"

  if image and valid_width_and_height?(height, width) and valid_hex_color?(color)
    resize_and_pad_with_color(image, width, height, color)
    content_type 'image/jpg'
    image.to_blob
  else
    redirect('/vanilla_ice')
  end
end

get '/rapper/:rapper/w/:width/h/:height/bg/:color' do
  image  =  assign_transparent_rapper_png("#{params[:rapper]}")
  width  =  "#{params[:width]}".to_i
  height =  "#{params[:height]}".to_i
  color  = "##{params[:color]}"

  if image and valid_width_and_height?(height, width) and valid_hex_color?(color)
    resize_and_pad_with_color(image, width, height, color)
    content_type 'image/jpg'
    image.to_blob
  else
    redirect('/vanilla_ice')
  end
end

# route methods for undefined API requests

not_found do
  error 400
end

error 401 do
  "{'error':'unauthorized', 'message':'You are not authorized to access this resource.'}"
end