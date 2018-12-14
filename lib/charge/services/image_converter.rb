require 'mini_magick'

require 'values/conversion_spec'

require 'tempfile'
require 'shellwords'

module Charge
   module Services
      class ImageConverter
         class << self
            def convert_image conversion_spec
               puts "Start convert image"
               input_path = conversion_spec.input_file.path
               output_path = conversion_spec.output_file.path
               begin
                  imagick = MiniMagick::Image.open input_path
                  resize_opt = self.build_resize_option conversion_spec
                  imagick.resize resize_opt unless resize_opt.nil?
                  imagick.quality conversion_spec.quality 
                  imagick.write output_path
                  puts "Image conversion successfull"
                  if imagick.type == "PNG"
                     puts "Optimizing PNG..."
                     self.optimize_png conversion_spec.output_file
                  end
                  puts "Conversion process complete!"
               rescue
                  puts "Image conversion failed!"
                  return false
               end
               return true
            end

            # JPEG conversion always converts to 100 quality "lossless"
            def convert_to_jpeg input_file, output_file
               begin
                  puts "Opening temp file '#{input_file.path}'..."
                  imagick = MiniMagick::Image.open input_file.path
                  if imagick.type == "JPEG"
                     puts "Skipping JPEG recompression. Image is already JPEG!"
                     imagick.write output_file.path
                     return true
                  end
                  imagick.format "jpeg"
                  imagick.quality 100
                  imagick.write output_file.path
                  puts "Conversion to JPEG success..."
                  puts "Wrote to #{output_file.path}..."
               rescue
                  puts "Conversion to JPEG failed!!!"
                  return false
               end
               return true
            end

            def optimize_png output_file
               png_file_path = output_file.path
               puts "Running png optimization..."
               cmd = "pngquant --force --strip #{png_file_path.shellescape} --out #{png_file_path.shellescape}"
               output_file.close
               system(cmd)
               puts "pngquant failed" unless $?.exitstatus == 0
               output_file.open
               puts "png optimization complete!"
               puts output_file.length
            end

            def build_resize_option conversion_spec
               return nil if conversion_spec.bounding_box.nil?
               size_str = conversion_spec.bounding_box.to_s 
               # '>' option means "shrink only"
               resize_opt = "#{size_str}x#{size_str}>"
               return resize_opt
            end
         end
      end
   end
end
