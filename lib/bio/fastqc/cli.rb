# -*- coding: utf-8 -*-

require 'thor'
require 'json'

module Bio
  module FastQC
    class CLI < Thor
      desc "parse [--format format] [filename]", "parse fastqc data in fastqc directory or zipfile, output in json, json-ld, or rdf-turtle format."
      option :format, :default => "json"
      def parse(file)
        data = Data.read(file)
        summary = Parser.new(data).summary
        puts Converter.new(summary).convert_to(options[:format])
      # rescue
      #   puts "Wrong input file type: specify fastqc result data, directory or zipfile"
      end
    end
  end
end
