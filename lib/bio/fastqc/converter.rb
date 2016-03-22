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
        when "tsv"
          to_tsv
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

      def to_tsv
        identifier = if @id
                       @id
                     else
                       @summary_json[:filename].split(".").first
                     end

        # return one-line tab separated value
        [
          identifier,
          @summary_json[:fastqc_version],
          @summary_json[:filename],
          @summary_json[:file_type],
          @summary_json[:encoding],
          @summary_json[:total_sequences],
          @summary_json[:filtered_sequences],
          @summary_json[:sequence_length],
          @summary_json[:min_length],
          @summary_json[:max_length],
          @summary_json[:mean_sequence_length],
          @summary_json[:median_sequence_length],
          @summary_json[:percent_gc],
          @summary_json[:total_duplicate_percentage],
          @summary_json[:overall_mean_quality_score],
          @summary_json[:overall_median_quality_score],
          @summary_json[:overall_n_content],
        ].join("\t")
      end
    end
  end
end
