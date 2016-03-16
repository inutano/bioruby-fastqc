# -*- coding: utf-8 -*-

module Bio
  module FastQC
    class Semantics
      def initialize(summary_json)
        @summary = summary_json
      end

      def merged_object
        {
          "@context" => jsonld_context,
          "@graph" => module_object_array.inject(&:merge),
        }
      end

      def module_object_array
        [
          fastqc_version,
          filename,
          file_type,
          encoding,
          total_sequences,
          filtered_sequences,
          sequence_length,
          percent_gc,
          per_base_sequence_quality,
          per_tile_sequence_quality,
          per_sequence_quality_scores,
          per_base_sequence_content,
          per_sequence_gc_content,
          per_base_n_content,
          sequence_length_distribution,
          total_duplicate_percentage,
          sequence_duplication_levels,
          overrepresented_sequences,
          adapter_content,
          kmer_content,
          min_length,
          max_length,
          overall_mean_quality_score,
          overall_median_quality_score,
          overall_n_content,
          mean_sequence_length,
          median_sequence_length,
        ]
      end

      def base_stat_class(base)
        case base
        when /-/ # when the base position is range like "50-100"
          "BaseRangeStatistics"
        else
          "ExactBaseStatistics"
        end
      end

      def fastqc_version
      end

      def filename
        {
          "filename" => @summary[:filename],
        }
      end

      def file_type
        {
          "fileType" => @summary[:file_type],
        }
      end

      def encoding
        {
          "encoding" => @summary[:encoding],
        }
      end

      def total_sequences
        {
          "totalSequences" => {
            "@type" => "SequenceReadContent",
            "hasUnit" => "countUnit",
            "value" => summary[:total_sequences],
          }
        }
      end

      def filtered_sequences
        {
          "filteredSequences" => {
            "@type" => "SequenceReadContent",
            "hasUnit" => "countUnit",
            "value" => summary[:filtered_sequences],
          }
        }
      end

      def sequence_length
        {
          "sequenceLength" => {
            "@type" => "SequenceReadLength",
            "value" => summary[:sequence_length],
          }
        }
      end

      def percent_gc
        {
          "percentGC" => {
            "@type" => "NucleotideBaseContent",
            "value" => summary[:percent_gc],
          }
        }
      end

      def per_base_sequence_quality
        {
          "hasMatrix" => {
            "@type" => "PerBaseSequenceQuality",
            "hasRow" => per_base_sequence_quality_rows(summary[:per_base_sequence_quality]),
          }
        }
      end

      def per_base_sequence_quality_rows(matrix)
        matrix.map.with_index do |row, i|
          base = row[0]
          mean = row[1]
          median = row[2]
          lower_quartile = row[3]
          upper_quartile = row[4]
          tenth_percentile = row[5]
          ninetieth_percentile = row[6]

          {
            "@type" => [
              "Row",
              base_stat_class(base),
            ],
            "rowIndex" => i,
            "basePosition" => base,
            "meanBaseCallQuality" => {
              "@type" => "PhredQualityScore",
              "value" => mean,
            },
            "medianBaseCallQuality" => {
              "@type" => "PhredQualityScore",
              "value" => median,
            },
            "baseCallQualityLowerQuartile" => {
              "@type" => "PhredQualityScore",
              "value" => lower_quartile,
            },
            "baseCallQualityUpperQuartile" => {
              "@type" => "PhredQualityScore",
              "value" => upper_quartile,
            },
            "baseCallQuality10thPercentile" => {
              "@type" => "PhredQualityScore",
              "value" => tenth_percentile,
            },
            "baseCallQuality90thPercentile" => {
              "@type" => "PhredQualityScore",
              "value" => ninetieth_percentile,
            },
          }
        end
      end

      def per_tile_sequence_quality
      end

      def per_sequnce_quality_scores
        {
          "hasMatrix" => {
            "@type" => "PerSequnceQualityScores",
            "hasRow" => per_sequnce_quality_scores_rows(summary[:per_sequnce_quality_scores]),
          }
        }
      end

      def per_sequnce_quality_scores_rows(matrix)
        matrix.map.with_index do |row, i|
          quality = row[0]
          count = row[1]
          {
            "@type" => "Row",
            "rowIndex" => i,
            "baseCallQuality" => {
              "@type" => "PhredQualityScore",
              "value" => quality,
            },
            "sequenceReadCount" => {
              "@type" => "SequenceReadContent",
              "value" => count,
            },
          }
        end
      end

      def per_base_sequence_content
        {
          "hasMatrix" => {
            "@type" => "PerBaseSequenceContent",
            "hasRow" => per_base_sequence_content_rows(summary[:per_base_sequence_content]),
          }
        }
      end

      def per_base_sequence_content_rows(matrix)
        matrix.map.with_index do |row, i|
          base = row[0]
          guanine = row[1]
          adenine = row[2]
          thymine = row[3]
          chytosine = row[4]
          {
            "@type" => [
              "Row",
              base_stat_class(base),
            ],
            "rowIndex" => i,
            "basePosition" => base,
            "percentGuanine" => {
              "@type" => "NucleotideBaseContent",
              "hasUnit" => "percentage",
              "value" => guanine,
            },
            "percentAdenine" => {
              "@type" => "NucleotideBaseContent",
              "hasUnit" => "percentage",
              "value" => adenine,
            },
            "percentThymine" => {
              "@type" => "NucleotideBaseContent",
              "hasUnit" => "percentage",
              "value" => thymine,
            },
            "percentCytosine" => {
              "@type" => "NucleotideBaseContent",
              "hasUnit" => "percentage",
              "value" => chytosine,
            },
          }
        end
      end

      def per_sequence_gc_content
        {
          "hasMatrix" => {
            "@type" => "PerSequenceGCContent",
            "hasRow" => per_sequence_gc_content_rows(summary[:per_sequence_gc_content]),
          }
        }
      end

      def per_sequence_gc_content_rows(matrix)
        matrix.map.with_index do |row, i|
          gc_content = row[0]
          count = row[1]
          {
            "@type" => "Row",
            "rowIndex" => i,
            "percentGC" => {
              "@type" => "NucleotideBaseContent",
              "value" => gc_content,
            },
            "sequenceReadCount" => {
              "@type" => "SequenceReadContent",
              "value" => count,
            },
          }
        end
      end

      def per_base_n_content
        {
          "hasMatrix" => {
            "@type" => "PerBaseNContent",
            "hasRow" => per_base_n_content_rows(summary[:per_base_n_content]),
          }
        }
      end

      def per_base_n_content_rows(matrix)
        matrix.map.with_index do |row, i|
          base = row[0]
          n_count = row[1]
          {
            "@type" => [
              "Row",
              base_stat_class(base),
            ],
            "rowIndex" => i,
            "basePosition" => base,
            "nCount" => {
              "@type" => "NContent",
              "hasUnit" => "countUnit",
              "value" => n_count,
            },
          }
        end
      end

      def sequence_length_distribution
        {
          "hasMatrix" => {
            "@type" => "SequenceLengthDistribution",
            "hasRow" => sequence_length_distribution_rows(summary[:sequence_length_distribution]),
          }
        }
      end

      def sequence_length_distribution_rows(matrix)
        matrix.map.with_index do |row, i|
          length = row[0]
          count = row[1]
          {
            "@type" => "Row",
            "rowIndex" => i,

            "sequenceReadLength" => {
              "@type" => "SequenceReadLength",
              "hasUnit" => "countUnit",
              "value" => length,
            },
            "sequenceReadCount" => {
              "@type" => "SequenceReadContent",
              "hasUnit" => "countUnit",
              "value" => count,
            },
          }
        end
      end

      def total_duplicate_percentage
      end

      def sequence_duplication_levels
        {
          "hasMatrix" => {
            "@type" => "SequenceDuplicationLevels",
            "hasRow" => sequence_duplication_levels_rows(summary[:sequence_duplication_levels]),
          }
        }
      end

      def sequence_duplication_levels_rows(matrix)
        matrix.map.with_index do |row, i|
          duplication_level = row[0]
          relative_count = row[1]
          {
            "@type" => "Row",
            "rowIndex" => i,

            "sequenceDuplicationLevel" => {
              "@type" => "SequenceDuplicationLevel",
              "hasUnit" => "countUnit",
              "value" => duplication_level,
            },
            "sequenceReadRelativeCount" => {
              "@type" => "SequenceReadContent",
              "hasUnit" => "countUnit",
              "value" => relative_count,
            },
          }
        end
      end

      def overrepresented_sequences
        {
          "hasMatrix" => {
            "@type" => "OverrepresentedSequences",
            "hasRow" => overrepresented_sequences_rows(summary[:overrepresented_sequences]),
          }
        }
      end

      def overrepresented_sequences_rows(matrix)
        matrix.map.with_index do |row, i|
          sequence = row[0]
          count = row[1]
          percentage = row[2]
          possible_source = row[3]
          {
            "@type" => "Row",
            "rowIndex" => i,
            "overrepresentedSequence" => sequence,
            "sequenceReadCount" => {
              "@type" => "SequenceReadContent",
              "hasUnit" => "countUnit",
              "value" => count,
            },
            "sequenceReadPercentage" => {
              "@type" => "SequenceReadContent",
              "hasUnit" => "percentage",
              "value" => percentage,
            },
            "possibleSourceOfSequence" => possible_source,
          }
        end
      end

      def adapter_content
      end

      def kmer_content
        {
          "hasMatrix" => {
            "@type" => "KmerContent",
            "hasRow" => kmer_content_rows(summary[:kmer_content]),
          }
        }
      end

      def kmer_content_rows(matrix)
        matrix.map.with_index do |row, i|
          sequence = row[0]
          count = row[1]
          ratio_overall = row[2]
          ratio_max = row[3]
          ratio_max_position = row[4]
          {
            "@type" => "Row",
            "rowIndex" => i,
            "kmerSequence" => sequence,
            "sequenceReadCount" => {
              "@type" => "SequenceReadContent",
              "hasUnit" => "countUnit",
              "value" => count,
            },
            "observedPerExpectedOverall" => {
              "@type" => "SequenceReadContent",
              "hasUnit" => "ratio",
              "value" => ratio_overall,
            },
            "observedPerExpectedMax" => {
              "@type" => "SequenceReadContent",
              "hasUnit" => "ratio",
              "value" => ratio_max,
            },
            "observedPerExpectedMaxPosition" => ratio_max_position,
          }
        end
      end

      def min_length
        {
          "minSequenceLength" => {
            "@type" => "SequenceReadLength",
            "value" => @summary[:min_length],
          }
        }
      end

      def max_length
        {
          "maxSequenceLength" => {
            "@type" => "SequenceReadLength",
            "value" => @summary[:max_length],
          }
        }
      end

      def mean_sequence_length
        {
          "meanSequenceLength" => {
            "@type" => "SequenceReadLength",
            "value" => @summary[:mean_sequence_length],
          }
        }
      end

      def median_sequence_length
        {
            "medianSequenceLength" => {
            "@type" => "SequenceReadLength",
            "value" => @summary[:median_sequence_length],
          }
        }
      end

      def overall_mean_quality_score
        {
          "overallMeanBaseCallQuality" => {
            "@type" => "PhredQualityScore",
            "value" => @summary[:overall_mean_quality_score],
          }
        }
      end

      def overall_median_quality_score
        {
          "overallMedianBaseCallQuality" => {
            "@type" => "PhredQualityScore",
            "value" => @summary[:overall_median_quality_score],
          }
        }
      end

      def overall_n_content
        {
          "overallNContent" => {
            "@type" => "NContent",
            "value" => @summary[:overall_n_content],
          }
        }
      end

      ## Generate JSON-LD context object

      def jsonld_context
        # definition of imported terms in @context
        object = imported_keywords

        # definition of local ontology terms in @context
        sos_terms.each do |term|
          object[term] = {}
          object[term]["@id"] = "http://me.com/sos#" + term
          object[term]["@type"] = "@id"
        end

        object
      end

      def imported_keywords
        {
          "countUnit" => "http://purl.obolibrary.org/obo/UO_0000189",
          "percent" => "http://purl.obolibrary.org/obo/UO_0000187",
          "ratio" => "http://purl.obolibrary.org/obo/UO_0000190",
          "value" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#value",
        }
      end

      def sos_terms
        [
          sos_class,
          sos_predicates,
        ].flatten
      end

      def sos_class
        [
          sos_class_general,
          sos_class_fastqc_modules,
          sos_class_for_values,
        ].flatten
      end

      def sos_class_general
        [
          "SequenceStatisticsReport",
          "SequenceStatisticsMatrix",
          "Row",
          "ExactBaseStatistics",
          "BaseRangeStatistics",
        ]
      end

      def sos_class_fastqc_modules
        [
          "PerBaseSequenceQuality",
          "PerTileSequenceQuality",
          "PerSequnceQualityScores",
          "PerBaseSequenceContent",
          "PerSequenceGCContent",
          "PerBaseNContent",
          "SequenceLengthDistribution",
          "SequenceDuplicationLevels",
          "OverrepresentedSequences",
          "KmerContent",
        ]
      end

      def sos_class_for_values
        [
          "PhredQualityScore",
          "NucleotideBaseContent",
          "SequenceReadContent",
          "SequenceReadLength",
          "SequenceDuplicationLevel",
        ]
      end

      def sos_predicates
        [
          sos_predicates_general,
          sos_predicates_matrix,
          sos_predicates_row,
          sos_predicates_value,
          sos_predicates_quanto,
        ].flatten
      end

      def sos_predicates_general
        [
          "hasMatrix",
          "filename",
          "fileType",
          "encoding",
          "totalSequences",
          "filteredSequences",
          "sequenceLength",
          "percentGC",
        ]
      end

      def sos_predicates_matrix
        [
          "hasRow",
        ]
      end

      def sos_predicates_row
        [
          "rowIndex",
          "baseCallQuality",
          "baseCallQuality10thPercentile",
          "baseCallQuality90thPercentile",
          "baseCallQualityLowerQuartile",
          "baseCallQualityUpperQuartile",
          "basePosition",
          "kmerSequence",
          "meanBaseCallQuality",
          "medianBaseCallQuality",
          "nCount",
          "observedPerExpectedMax",
          "observedPerExpectedMaxPosition",
          "observedPerExpectedOverall",
          "overrepresentedSequence",
          "percentAdenine",
          "percentCytosine",
          "percentGC",
          "percentGuanine",
          "percentThymine",
          "possibleSourceOfSequence",
          "sequenceDuplicationLevel",
          "sequenceReadCount",
          "sequenceReadLength",
          "sequenceReadPercentage",
          "sequenceReadRelativeCount",
        ]
      end

      def sos_predicates_value
        [
          "hasUnit",
        ]
      end

      def sos_predicates_quanto
        [
          "minSequenceLength",
          "maxSequenceLength",
          "meanSequenceLength",
          "medianSequenceLength",
          "overallMeanBaseCallQuality",
          "overallMedianBaseCallQuality",
          "overallNContent",
        ]
      end
    end
  end
end
