# -*- coding: utf-8 -*-

require 'zip'

module Bio
  module FastQC
	  class Data
			class << self
				def read(file)
					read_zipfile(file)
				rescue Zip::Error
					if File.file?(file)
  					read_flatfile(file)
					else
						read_dir(file)
					end
				end

				def read_zipfile(file)
					Zip::File.open(file) do |zipfile|
						zipfile.glob('*/fastqc_data.txt').first.get_input_stream.read
					end
				end

				def read_flatfile(file)
					open(file).read
				end

				def read_dir(file)
					open(File.join(file, "fastqc_data.txt")).read
				rescue Errno::ENOENT
					puts "FastQC data file fastqc_data.txt not found"
					exit
				end
  		end
		end
	end
end
