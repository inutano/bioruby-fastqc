# -*- coding: utf-8 -*-

module Bio
  module FastQC
    class Converter
      def initialize(summary_json)
        @summary_json = summary_json
      end

      def convert_to(format)
        case format
        when "json"
          to_json
        when "json-ld"
          to_jsonld
        end
      end

      def to_json
        JSON.dump(@summary_json)
      end

      def to_jsonld
        json_ld_object = Semantics.new(@summary_json)
        JSON.dump(json_ld_object)
      end
    end
  end
end
