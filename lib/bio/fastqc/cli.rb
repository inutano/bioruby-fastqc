# -*- coding: utf-8 -*-

require 'thor'
require 'json'

module Bio
  module FastQC
    class CLI < Thor
      desc "parse [--format format] [--outdir output directory] [filepath, ..]", "parse fastqc data in directory or zipfile. output format: json, json-ld, turtle, or tsv"
      option :format, :default => "json"
      option :outdir, :default => nil
      def parse(*files)
        files.each do |file|
          data = Data.read(file)
          summary = Parser.new(data).summary
          out = Converter.new(summary).convert_to(options[:format])

          outdir_path = options[:outdir]
          if outdir_path && File.directory?(outdir_path)
            filename_org = File.basename(summary[:filename])
            fpath = File.join(outdir_path, filename_org + "." + options[:format])
            open(fpath, "w"){|f| f.puts(out) }
          else
            puts out
          end
        end
      end
    end
  end
end
