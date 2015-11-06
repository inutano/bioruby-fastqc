# -*- coding: utf-8 -*-

require 'thor'
require 'json'

module Bio
  module FastQC
    class CLI < Thor
      desc "parse [filename]...", "parse fastqc data in fastqc directory or zipfile, output in json format"
      def parse(*files)
        files.each do |file|
          puts JSON.dump(Parser.new(Data.read(file)).summary)
        end
      rescue
        puts "Wrong input file type: specify fastqc result data, directory or zipfile"
      end
    end
  end
end
