# -*- coding: utf-8 -*-

require 'rdf/turtle'

module Bio
  module FastQC
    class IO
      def initialize(fastqc_object, id: nil)
        @fastqc_object = fastqc_object
        @id = id
      end

      def write(output_file, format)
        case format
        when "json"
          write_json(output_file)
        when "json-ld", "jsonld"
          write_jsonld(output_file)
        when "turtle", "ttl"
          write_ttl(output_file)
        when "tsv"
          write_tsv(output_file)
        end
      end

      def write_json(output_file)
        json = Converter.new(@fastqc_object, id: @id).to_json
        open(output_file, 'w'){|file| file.puts(json) }
      end

      def write_jsonld(output_file)
        jsonld = Converter.new(@fastqc_object, id: @id).to_jsonld
        open(output_file, 'w'){|file| file.puts(jsonld) }
      end

      def write_ttl(output_file)
        semantics = Semantics.new(@fastqc_object, id: @id)
        graph = semantics.turtle_graph
        prefixes = semantics.turtle_prefixes
        RDF::Turtle::Writer.open(output_file, prefixes: prefixes) do |writer|
          writer << graph
        end
      end

      def write_tsv(output_file)
        tsv = Converter.new(@fastqc_object, id: @id).to_tsv
        open(output_file, 'w'){|file| file.puts(tsv) }
      end
    end
  end
end
