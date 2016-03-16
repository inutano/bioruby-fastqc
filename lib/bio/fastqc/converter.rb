# -*- coding: utf-8 -*-

module Bio
  module FastQC
    class Converter
      def initialize(summary_json, id: nil)
        @id = id
        @summary_json = summary_json
      end

      def convert_to(format)
        case format
        when "json"
          to_json
        when "json-ld"
          to_jsonld
        when "turtle"
          to_turtle
        end
      end

      def to_json
        json = if @id
                 { @id => @summary_json }
               else
                 @summary_json
               end
        JSON.dump(json)
      end

      def to_jsonld
        json_ld_object = Semantics.new(@summary_json, id: @id).json_ld_object
        JSON.dump(json_ld_object)
      end

      def to_turtle
        Semantics.new(@summary_json, id: @id).turtle
      end

      def to_ttl
        to_turtle
      end
    end
  end
end
