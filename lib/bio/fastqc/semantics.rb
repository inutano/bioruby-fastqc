# -*- coding: utf-8 -*-

require 'json/ld'
require 'rdf/turtle'

module Bio
  module FastQC
    class Semantics
      def initialize(fastqc_object, id: nil)
        @id = id
        @fastqc_object = fastqc_object
      end

      def rdf_version
        "0.1.0"
      end

      def turtle
        turtle_graph.dump(:ttl, prefixes: turtle_prefixes)
      end

      def turtle_graph
        RDF::Graph.new << JSON::LD::API.toRdf(json_ld_object)
      end

      def turtle_prefixes
        {
          "uo" => "http://purl.obolibrary.org/obo/",
          "rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
          "dcterms" => "http://purl.org/dc/terms/",
          "pav" => "http://purl.org/pav/",
          "foaf" => "http://xmlns.com/foaf/0.1/",
        }
      end

      def json_ld_object
        object = [object_core, static_value_modules].flatten.inject(&:merge)
        object["hasMatrix"] = matrix_modules
        object
      end

      def uri_base
        "http://purl.jp/bio/01/quanto"
      end

      def identifier_literal
        @id ? @id : "QNT" + @fastqc_object[:filename].split(".")[0]
      end

      def identifier_uri
        uri_base + "/resource/" + identifier_literal
      end

      def object_core
        {
          "@context" => jsonld_context,
          "@id" => identifier_uri,
          "@type" => "SequenceStatisticsReport",
          "dcterms:identifier" => identifier_literal,
          "dcterms:contributor" => ["Tazro Ohta", "Shuichi Kawashima"],
          "dcterms:created" => Time.now.strftime("%Y-%m-%d"),
          "dcterms:license" => "http://creativecommons.org/licenses/by-sa/2.1/jp/deed.en",
          "dcterms:publisher" => "http://dbcls.rois.ac.jp/",
          "pav:version" => rdf_version,
          "foaf:page" => "http://quanto.dbcls.jp",
        }
      end

      def static_value_modules
        [
          fastqc_version,
          filename,
          file_type,
          encoding,
          total_sequences,
          filtered_sequences,
          sequence_length,
          percent_gc,
          total_duplicate_percentage,
          min_length,
          max_length,
          overall_mean_quality_score,
          overall_median_quality_score,
          overall_n_content,
          mean_sequence_length,
          median_sequence_length,
        ]
      end

      def matrix_modules
        [
          per_base_sequence_quality,
          per_tile_sequence_quality,
          per_sequence_quality_scores,
          per_base_sequence_content,
          per_sequence_gc_content,
          per_base_n_content,
          sequence_length_distribution,
          sequence_duplication_levels,
          overrepresented_sequences,
          adapter_content,
          kmer_content,
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
        {
          "fastqcVersion" => @fastqc_object[:fastqc_version],
        }
      end

      def filename
        {
          "filename" => @fastqc_object[:filename],
        }
      end

      def file_type
        {
          "fileType" => @fastqc_object[:file_type],
        }
      end

      def encoding
        {
          "encoding" => @fastqc_object[:encoding],
        }
      end

      def total_sequences
        {
          "totalSequences" => {
            "@type" => "SequenceReadContent",
            "hasUnit" => "uo:CountUnit",
            "rdf:value" => @fastqc_object[:total_sequences],
          }
        }
      end

      def filtered_sequences
        {
          "filteredSequences" => {
            "@type" => "SequenceReadContent",
            "hasUnit" => "uo:CountUnit",
            "rdf:value" => @fastqc_object[:filtered_sequences],
          }
        }
      end

      def sequence_length
        {
          "sequenceLength" => {
            "@type" => "SequenceReadLength",
            "hasUnit" => "uo:CountUnit",
            "rdf:value" => @fastqc_object[:sequence_length],
          }
        }
      end

      def percent_gc
        {
          "percentGC" => {
            "@type" => "NucleotideBaseContent",
            "hasUnit" => "uo:CountUnit",
            "rdf:value" => @fastqc_object[:percent_gc],
          }
        }
      end

      def per_base_sequence_quality
        {
          "@type" => "PerBaseSequenceQuality",
          "hasRow" => per_base_sequence_quality_rows(@fastqc_object[:per_base_sequence_quality]),
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
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => mean,
            },
            "medianBaseCallQuality" => {
              "@type" => "PhredQualityScore",
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => median,
            },
            "baseCallQualityLowerQuartile" => {
              "@type" => "PhredQualityScore",
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => lower_quartile,
            },
            "baseCallQualityUpperQuartile" => {
              "@type" => "PhredQualityScore",
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => upper_quartile,
            },
            "baseCallQuality10thPercentile" => {
              "@type" => "PhredQualityScore",
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => tenth_percentile,
            },
            "baseCallQuality90thPercentile" => {
              "@type" => "PhredQualityScore",
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => ninetieth_percentile,
            },
          }
        end
      end

      def per_tile_sequence_quality
        {}
      end

      def per_sequence_quality_scores
        {
          "@type" => "PerSequnceQualityScores",
          "hasRow" => per_sequence_quality_scores_rows(@fastqc_object[:per_sequence_quality_scores]),
        }
      end

      def per_sequence_quality_scores_rows(matrix)
        matrix.map.with_index do |row, i|
          quality = row[0]
          count = row[1]
          {
            "@type" => "Row",
            "rowIndex" => i,
            "baseCallQuality" => {
              "@type" => "PhredQualityScore",
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => quality,
            },
            "sequenceReadCount" => {
              "@type" => "SequenceReadContent",
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => count,
            },
          }
        end
      end

      def per_base_sequence_content
        {
          "@type" => "PerBaseSequenceContent",
          "hasRow" => per_base_sequence_content_rows(@fastqc_object[:per_base_sequence_content]),
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
              "hasUnit" => "uo:Percentage",
              "rdf:value" => guanine,
            },
            "percentAdenine" => {
              "@type" => "NucleotideBaseContent",
              "hasUnit" => "uo:Percentage",
              "rdf:value" => adenine,
            },
            "percentThymine" => {
              "@type" => "NucleotideBaseContent",
              "hasUnit" => "uo:Percentage",
              "rdf:value" => thymine,
            },
            "percentCytosine" => {
              "@type" => "NucleotideBaseContent",
              "hasUnit" => "uo:Percentage",
              "rdf:value" => chytosine,
            },
          }
        end
      end

      def per_sequence_gc_content
        {
          "@type" => "PerSequenceGCContent",
          "hasRow" => per_sequence_gc_content_rows(@fastqc_object[:per_sequence_gc_content]),
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
              "hasunit" => "uo:Percent",
              "rdf:value" => gc_content,
            },
            "sequenceReadCount" => {
              "@type" => "SequenceReadContent",
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => count,
            },
          }
        end
      end

      def per_base_n_content
        {
          "@type" => "PerBaseNContent",
          "hasRow" => per_base_n_content_rows(@fastqc_object[:per_base_n_content]),
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
              "hasUnit" => "uo:Percentage",
              "rdf:value" => n_count,
            },
          }
        end
      end

      def sequence_length_distribution
        {
          "@type" => "SequenceLengthDistribution",
          "hasRow" => sequence_length_distribution_rows(@fastqc_object[:sequence_length_distribution]),
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
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => length,
            },
            "sequenceReadCount" => {
              "@type" => "SequenceReadContent",
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => count,
            },
          }
        end
      end

      def total_duplicate_percentage
        {}
      end

      def sequence_duplication_levels
        {
          "@type" => "SequenceDuplicationLevels",
          "hasRow" => sequence_duplication_levels_rows(@fastqc_object[:sequence_duplication_levels]),
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
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => duplication_level,
            },
            "sequenceReadRelativeCount" => {
              "@type" => "SequenceReadContent",
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => relative_count,
            },
          }
        end
      end

      def overrepresented_sequences
        {
          "@type" => "OverrepresentedSequences",
          "hasRow" => overrepresented_sequences_rows(@fastqc_object[:overrepresented_sequences]),
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
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => count,
            },
            "sequenceReadPercentage" => {
              "@type" => "SequenceReadContent",
              "hasUnit" => "uo:Percentage",
              "rdf:value" => percentage,
            },
            "possibleSourceOfSequence" => possible_source,
          }
        end
      end

      def adapter_content
        {}
      end

      def kmer_content
        {
          "@type" => "KmerContent",
          "hasRow" => kmer_content_rows(@fastqc_object[:kmer_content]),
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
              "hasUnit" => "uo:CountUnit",
              "rdf:value" => count,
            },
            "observedPerExpectedOverall" => {
              "@type" => "SequenceReadContent",
              "hasUnit" => "uo:Ratio",
              "rdf:value" => ratio_overall,
            },
            "observedPerExpectedMax" => {
              "@type" => "SequenceReadContent",
              "hasUnit" => "uo:Ratio",
              "rdf:value" => ratio_max,
            },
            "observedPerExpectedMaxPosition" => ratio_max_position,
          }
        end
      end

      def min_length
        {
          "minSequenceLength" => {
            "@type" => "SequenceReadLength",
            "hasUnit" => "uo:CountUnit",
            "rdf:value" => @fastqc_object[:min_length],
          }
        }
      end

      def max_length
        {
          "maxSequenceLength" => {
            "@type" => "SequenceReadLength",
            "hasUnit" => "uo:CountUnit",
            "rdf:value" => @fastqc_object[:max_length],
          }
        }
      end

      def mean_sequence_length
        {
          "meanSequenceLength" => {
            "@type" => "SequenceReadLength",
            "hasUnit" => "uo:CountUnit",
            "rdf:value" => @fastqc_object[:mean_sequence_length],
          }
        }
      end

      def median_sequence_length
        {
            "medianSequenceLength" => {
            "@type" => "SequenceReadLength",
            "hasUnit" => "uo:CountUnit",
            "rdf:value" => @fastqc_object[:median_sequence_length],
          }
        }
      end

      def overall_mean_quality_score
        {
          "overallMeanBaseCallQuality" => {
            "@type" => "PhredQualityScore",
            "hasUnit" => "uo:CountUnit",
            "rdf:value" => @fastqc_object[:overall_mean_quality_score],
          }
        }
      end

      def overall_median_quality_score
        {
          "overallMedianBaseCallQuality" => {
            "@type" => "PhredQualityScore",
            "hasUnit" => "uo:CountUnit",
            "rdf:value" => @fastqc_object[:overall_median_quality_score],
          }
        }
      end

      def overall_n_content
        {
          "overallNContent" => {
            "@type" => "NContent",
            "hasUnit" => "uo:Percentage",
            "rdf:value" => @fastqc_object[:overall_n_content],
          }
        }
      end

      #
      # Generate JSON-LD context object
      #

      def jsonld_context
        # definition of imported terms in @context
        object = turtle_prefixes

        # definition of local ontology terms
        domain = uri_base + "/ontology/sos#"

        # definition of class in @context
        sos_class.each do |term|
          object[term] = {}
          object[term]["@id"] = domain + term
          object[term]["@type"] = "@id"
        end

        # definition of object properties in @context
        sos_object_properties.each do |term|
          object[term] = {}
          object[term]["@id"] = domain + term
          object[term]["@type"] = "@id"
        end

        sos_data_properties_string.each do |term|
          object[term] = {}
          object[term]["@id"] = domain + term
          object[term]["@type"] = "http://www.w3.org/2001/XMLSchema#string"
        end

        sos_data_properties_integer.each do |term|
          object[term] = {}
          object[term]["@id"] = domain + term
          object[term]["@type"] = "http://www.w3.org/2001/XMLSchema#integer"
        end

        sos_data_properties_float.each do |term|
          object[term] = {}
          object[term]["@id"] = domain + term
          object[term]["@type"] = "http://www.w3.org/2001/XMLSchema#float"
        end

        object
      end

      #
      # definition of classes
      #

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

      #
      # definition of predicates
      #

      def sos_object_properties
        [
          "hasMatrix",
          "totalSequences",
          "filteredSequences",
          "sequenceLength",
          "percentGC",
          "hasRow",
          "basePosition",
          "kmerSequence",
          "meanBaseCallQuality",
          "medianBaseCallQuality",
          "nCount",
          "observedPerExpectedMax",
          "observedPerExpectedMaxPosition",
          "observedPerExpectedOverall",
          "percentAdenine",
          "percentCytosine",
          "percentGC",
          "percentGuanine",
          "percentThymine",
          "sequenceDuplicationLevel",
          "sequenceReadCount",
          "sequenceReadLength",
          "sequenceReadPercentage",
          "sequenceReadRelativeCount",
          "hasUnit",
          "overallMeanBaseCallQuality",
          "overallMedianBaseCallQuality",
          "overallNContent",
        ]
      end

      def sos_data_properties_string
        [
          "fastqcVersion",
          "filename",
          "fileType",
          "encoding",
          "possibleSourceOfSequence",
          "overrepresentedSequence",
        ]
      end

      def sos_data_properties_integer
        [
          "rowIndex",
        ]
      end

      def sos_data_properties_float
        [
          "baseCallQuality",
          "baseCallQuality10thPercentile",
          "baseCallQuality90thPercentile",
          "baseCallQualityLowerQuartile",
          "baseCallQualityUpperQuartile",
          "minSequenceLength",
          "maxSequenceLength",
          "meanSequenceLength",
          "medianSequenceLength",
        ]
      end
    end
  end
end
