require 'sinatra'
require 'json'
require 'pp' # for pretty debugging output
require 'mini_magick'
require 'pry'

helpers do

end

# trying to test if mini_magick is installed correctly
get '/vanilla_ice' do
  image = MiniMagick::Image.open('image/vanilla_ice_white_bg.jpg')
  content_type 'image/jpg'
  image.to_blob
end

get '/vanilla_ice/:percentage/percent' do
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

get '/vanilla_ice/:width/width/:height/height' do
  width = "#{params[:width]}".to_i
  height = "#{params[:height]}".to_i
  color = '#FFFFFF'
  if width > 0 && height > 0
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

# route methods for undefined API requests
not_found do
  error 400
end

error 401 do
  "{'error':'unauthorized', 'message':'You are not authorized to access this resource.'}"
end