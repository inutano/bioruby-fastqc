# -*- coding: utf-8 -*-

require 'thor'
require 'json'

module Bio
  module FastQC
    class CLI < Thor
      desc "parse [filename]", "parse fastqc data in fastqc directory or zipfile"
      def parse(file)
        puts JSON.dump(Parser.new(Data.read(file)).summary)
      end
    end
  end
end
