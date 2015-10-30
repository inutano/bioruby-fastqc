# -*- coding: utf-8 -*-

require 'thor'

module Bio
  module FastQC
    class CLI < Thor
      desc "parse fastqc result", "parse fastqc_data.txt in DIR or ZIPFILE from fastqc command."
      def parse(file)
        puts "parsed :D"
      end
    end
  end
end
