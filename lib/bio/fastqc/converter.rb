# -*- coding: utf-8 -*-

module Bio
  module FastQC
    class Converter
      def initialize(fastqc_object, id: nil, runid: nil)
        @id = id
        @runid = runid
        @fastqc_object = fastqc_object
      end

      def convert_to(format)
        case format
        when "json"
          to_json
        when "json-ld", "jsonld"
          to_jsonld
        when "turtle", "ttl"
          to_turtle
        when "tsv"
          to_tsv
        end
      end

      def to_json
        json = if @id
                 { @id => @fastqc_object }
               else
                 @fastqc_object
               end
        JSON.dump(json)
      end

      def to_jsonld
        json_ld_object = Semantics.new(@fastqc_object, id: @id, runid: @runid).json_ld_object
        JSON.dump(json_ld_object)
      end

      def to_turtle
        Semantics.new(@fastqc_object, id: @id, runid: @runid).turtle
      end

      def to_ttl
        to_turtle
      end

      def to_tsv
        identifier = if @id
                       @id
                     else
                       @fastqc_object[:filename].split(".").first
                     end

        # return one-line tab separated value
        [
          identifier,
          @fastqc_object[:fastqc_version],
          @fastqc_object[:filename],
          @fastqc_object[:file_type],
          @fastqc_object[:encoding],
          @fastqc_object[:total_sequences],
          @fastqc_object[:filtered_sequences],
          @fastqc_object[:sequence_length],
          @fastqc_object[:min_length],
          @fastqc_object[:max_length],
          @fastqc_object[:mean_sequence_length],
          @fastqc_object[:median_sequence_length],
          @fastqc_object[:percent_gc],
          @fastqc_object[:total_duplicate_percentage],
          @fastqc_object[:overall_mean_quality_score],
          @fastqc_object[:overall_median_quality_score],
          @fastqc_object[:overall_n_content],
        ].join("\t")
      end
    end
  end
end
