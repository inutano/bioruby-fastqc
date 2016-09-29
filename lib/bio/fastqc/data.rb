# -*- coding: utf-8 -*-

require 'zip'

module Bio
  module FastQC
    class Data
      class << self
        def read(file)
          read_zipfile(file)
        rescue Zip::Error
          read_flatfile(file)
        rescue Errno::EISDIR
          read_dir(file)
        end

        def read_zipfile(file)
          Zip::File.open(file) do |zipfile|
            d = zipfile.glob('*/fastqc_data.txt').first
            filenotfound(file) if !d
            d.get_input_stream.read
          end
        end

        def read_flatfile(file)
          open(file).read
        end

        def read_dir(file)
          open(File.join(file, "fastqc_data.txt")).read
        rescue Errno::ENOENT
          filenotfound(file)
        end

        def filenotfound(file)
          raise "FastQC data file fastqc_data.txt not found, input file: #{file}"
        end
      end
    end
  end
end
