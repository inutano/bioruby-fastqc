# -*- coding: utf-8 -*-

require 'rdf/turtle'

module Bio
  module FastQC
    class IO
      def initialize(summary_json, id: nil)
        @summary_json = summary_json
        @id = id
      end

      def write(output_file, format)
        case format
        when "json"
          write_json(output_file)
        when "json-ld"
          write_jsonld(output_file)
        when "turtle"
          write_ttl(output_file)
        when "tsv"
          write_tsv(output_file)
        end
      end

      def write_json(output_file)
        json = Converter.new(@summary_json, id: @id).to_json
        open(output_file, 'w'){|file| file.puts(json) }
      end

      def write_jsonld(output_file)
        jsonld = Converter.new(@summary_json, id: @id).to_jsonld
        open(output_file, 'w'){|file| file.puts(jsonld) }
      end

      def write_ttl(output_file)
        graph = Semantics.new(@summary_json, id: @id).turtle_graph
        RDF::Turtle::Writer.open(output_file) do |writer|
          writer << graph
        end
      end

      def write_tsv(output_file)
        tsv = Converter.new(@summary_json, id: @id).to_tsv
        open(output_file, 'w'){|file| file.puts(tsv) }
      end
    end
  end
end
