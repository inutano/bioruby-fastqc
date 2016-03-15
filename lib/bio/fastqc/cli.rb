# -*- coding: utf-8 -*-

require 'thor'
require 'json'

module Bio
  module FastQC
    class CLI < Thor
      desc "parse [filename]", "parse fastqc data in fastqc directory or zipfile, output in json format"
      def parse(file)
        data = Data.read(file)
        summary = Parser.new(data).summary
        puts JSON.dump(summary)
      rescue
        puts "Wrong input file type: specify fastqc result data, directory or zipfile"
      end
    end
  end
end
