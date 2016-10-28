# -*- coding: utf-8 -*-

require 'json/ld'
require 'rdf/turtle'

module Bio
  module FastQC
    class Semantics
      def initialize(fastqc_object, id: nil, tiny: true)
        @id = id
        @tiny = tiny
        @fastqc_object = fastqc_object
      end

      def rdf_version
        "0.2.0"
      end

      def turtle
        turtle_graph.dump(:ttl, prefixes: turtle_prefixes)
      end

      def turtle_graph
        RDF::Graph.new << JSON::LD::API.toRdf(json_ld_object)
      end

      def turtle_prefixes
        {
          "obo" => "http://purl.obolibrary.org/obo/",
          "rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
          "rdfs" => "http://www.w3.org/2000/01/rdf-schema#",
          "dcterms" => "http://purl.org/dc/terms/",
          "pav" => "http://purl.org/pav/",
          "foaf" => "http://xmlns.com/foaf/0.1/",
          "sos" => "http://purl.jp/bio/01/quanto/ontology/sos#",
          "quanto" => "http://purl.jp/bio/01/quanto/resource/",
          "sio" => "http://semanticscience.org/resource/",
          "xsd" => "http://www.w3.org/2001/XMLSchema#",
        }
      end

      def json_ld_object
        object = [object_core, static_value_modules, object_modules].flatten.inject(&:merge)
        if !@tiny
          object["hasMatrix"] = matrix_modules
        end
        object
      end

      def uri_base
        "http://purl.jp/bio/01/quanto"
      end

      def sra_identifier
        @fastqc_object[:filename].split(".")[0].split("_")[0]
      end

      def identifier_literal
        @id ? @id : "QNT_" + @fastqc_object[:filename].split(".")[0]
      end

      def identifier_uri
        "quanto:" + identifier_literal
      end

      def object_core
        {
          "@context" => jsonld_context,
          "@id" => identifier_uri,
          "@type" => "SequenceStatisticsReport",
          "dcterms:identifier" => identifier_literal,
          "dcterms:contributor" => ["Tazro Ohta", "Shuichi Kawashima"],
          "dcterms:created" => Time.now.strftime("%Y-%m-%d"),
          "dcterms:license" => {
            "@id" => "http://creativecommons.org/licenses/by-sa/4.0/",
          },
          "dcterms:publisher" => {
            "@id" => "http://dbcls.rois.ac.jp/",
          },
          "pav:version" => rdf_version,
          "foaf:page" => {
            "@id" => "http://quanto.dbcls.jp",
          },
          "rdfs:seeAlso" => {
            "@id" => "http://identifiers.org/insdc.sra/" + sra_identifier,
          },
        }
      end

      def static_value_modules
        [
          fastqc_version,
          filename,
          file_type,
          encoding,
        ]
      end

      def object_modules
        {
          "sio:SIO_000216" => [
            total_sequences,
            filtered_sequences,
            percent_gc,
            #total_duplicate_percentage,
            min_length,
            max_length,
            overall_mean_quality_score,
            overall_median_quality_score,
            overall_n_content,
            mean_sequence_length,
            median_sequence_length,
          ]
        }
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
          "@type" => "totalSequences",
          "sio:SIO_000221" => "obo:UO_0000244",
          "sio:SIO_000300" => {
            "@value" => @fastqc_object[:total_sequences],
            "@type" => "xsd:integer",
          },
        }
      end

      def filtered_sequences
        {
          "@type" => "filteredSequences",
          "sio:SIO_000221" => "obo:UO_0000244",
          "sio:SIO_000300" => {
            "@value" => @fastqc_object[:filtered_sequences],
            "@type" => "xsd:integer",
          }
        }
      end

      def sequence_length
        {
          "@type" => "SequenceReadLength",
          "sio:SIO_000221" => "obo:UO_0000244",
          "sio:SIO_000300" => {
            "@value" => @fastqc_object[:sequence_length],
            "@type" => "xsd:string",
          }
        }
      end

      def percent_gc
        {
          "@type" => "percentGC",
          "sio:SIO_000221" => "obo:UO_0000187",
          "sio:SIO_000300" => {
            "@value" => @fastqc_object[:percent_gc],
            "@type" => "xsd:decimal",
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
              "sio:SIO_000221" => "obo:UO_0000189",
              "sio:SIO_000300" => mean,
            },
            "medianBaseCallQuality" => {
              "@type" => "PhredQualityScore",
              "sio:SIO_000221" => "obo:UO_0000189",
              "sio:SIO_000300" => median,
            },
            "baseCallQualityLowerQuartile" => {
              "@type" => "PhredQualityScore",
              "sio:SIO_000221" => "obo:UO_0000189",
              "sio:SIO_000300" => lower_quartile,
            },
            "baseCallQualityUpperQuartile" => {
              "@type" => "PhredQualityScore",
              "sio:SIO_000221" => "obo:UO_0000189",
              "sio:SIO_000300" => upper_quartile,
            },
            "baseCallQuality10thPercentile" => {
              "@type" => "PhredQualityScore",
              "sio:SIO_000221" => "obo:UO_0000189",
              "sio:SIO_000300" => tenth_percentile,
            },
            "baseCallQuality90thPercentile" => {
              "@type" => "PhredQualityScore",
              "sio:SIO_000221" => "obo:UO_0000189",
              "sio:SIO_000300" => ninetieth_percentile,
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
              "sio:SIO_000221" => "obo:UO_0000189",
              "sio:SIO_000300" => quality,
            },
            "sequenceReadCount" => {
              "@type" => "SequenceReadAmount",
              "sio:SIO_000221" => "obo:UO_0000244",
              "sio:SIO_000300" => count,
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
              "@type" => "BaseRatio",
              "sio:SIO_000221" => "obo:UO_0000187",
              "sio:SIO_000300" => guanine,
            },
            "percentAdenine" => {
              "@type" => "BaseRatio",
              "sio:SIO_000221" => "obo:UO_0000187",
              "sio:SIO_000300" => adenine,
            },
            "percentThymine" => {
              "@type" => "BaseRatio",
              "sio:SIO_000221" => "obo:UO_0000187",
              "sio:SIO_000300" => thymine,
            },
            "percentCytosine" => {
              "@type" => "BaseRatio",
              "sio:SIO_000221" => "obo:UO_0000187",
              "sio:SIO_000300" => chytosine,
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
              "@type" => "BaseRatio",
              "sio:SIO_000221" => "obo:UO_0000187",
              "sio:SIO_000300" => gc_content,
            },
            "sequenceReadCount" => {
              "@type" => "SequenceReadAmount",
              "sio:SIO_000221" => "obo:UO_0000244",
              "sio:SIO_000300" => count,
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
              "@type" => "BaseRatio",
              "sio:SIO_000221" => "obo:UO_0000187",
              "sio:SIO_000300" => n_count,
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
              "sio:SIO_000221" => "obo:UO_0000244",
              "sio:SIO_000300" => length,
            },
            "sequenceReadCount" => {
              "@type" => "SequenceReadAmount",
              "sio:SIO_000221" => "obo:UO_0000244",
              "sio:SIO_000300" => count,
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
              "sio:SIO_000221" => "obo:UO_0000189",
              "sio:SIO_000300" => duplication_level,
            },
            "sequenceReadRelativeCount" => {
              "@type" => "SequenceReadAmount",
              "sio:SIO_000221" => "obo:UO_0000244",
              "sio:SIO_000300" => relative_count,
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
              "@type" => "SequenceReadAmount",
              "sio:SIO_000221" => "obo:UO_0000244",
              "sio:SIO_000300" => count,
            },
            "sequenceReadPercentage" => {
              "@type" => "SequenceReadRatio",
              "sio:SIO_000221" => "obo:UO_0000187",
              "sio:SIO_000300" => percentage,
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
              "@type" => "SequenceReadAmount",
              "sio:SIO_000221" => "obo:UO_0000244",
              "sio:SIO_000300" => count,
            },
            "observedPerExpectedOverall" => {
              "@type" => "SequenceReadAmount",
              "sio:SIO_000221" => "obo:Ratio",
              "sio:SIO_000300" => ratio_overall,
            },
            "observedPerExpectedMax" => {
              "@type" => "SequenceReadAmount",
              "sio:SIO_000221" => "obo:Ratio",
              "sio:SIO_000300" => ratio_max,
            },
            "observedPerExpectedMaxPosition" => ratio_max_position,
          }
        end
      end

      def min_length
        {
          "@type" => "minimumSequenceLength",
          "sio:SIO_000221" => "obo:UO_0000244",
          "sio:SIO_000300" => {
            "@value" => @fastqc_object[:min_length],
            "@type" => "xsd:integer",
          },
        }
      end

      def max_length
        {
          "@type" => "maxSequenceLength",
          "sio:SIO_000221" => "obo:UO_0000244",
          "sio:SIO_000300" => {
            "@value" => @fastqc_object[:max_length],
            "@type" => "xsd:integer",
          },
        }
      end

      def mean_sequence_length
        {
          "@type" => "meanSequenceLength",
          "sio:SIO_000221" => "obo:UO_0000244",
          "sio:SIO_000300" => {
            "@value" => @fastqc_object[:mean_sequence_length],
            "@type" => "xsd:decimal",
          },
        }
      end

      def median_sequence_length
        {
          "@type" => "medianSequenceLength",
          "sio:SIO_000221" => "obo:UO_0000244",
          "sio:SIO_000300" => {
            "@value" => @fastqc_object[:median_sequence_length],
            "@type" => "xsd:decimal",
          },
        }
      end

      def overall_mean_quality_score
        {
          "@type" => "meanBaseCallQuality",
          "sio:SIO_000221" => "obo:UO_0000189",
          "sio:SIO_000300" => {
            "@value" => @fastqc_object[:overall_mean_quality_score],
            "@type" => "xsd:decimal",
          },
        }
      end

      def overall_median_quality_score
        {
          "@type" => "medianBaseCallQuality",
          "sio:SIO_000221" => "obo:UO_0000189",
          "sio:SIO_000300" => {
            "@value" => @fastqc_object[:overall_median_quality_score],
            "@type" => "xsd:decimal",
          },
        }
      end

      def overall_n_content
        {
          "@type" => "nContent",
          "sio:SIO_000221" => "obo:UO_0000187",
          "sio:SIO_000300" => {
            "@value" => @fastqc_object[:overall_n_content],
            "@type" => "xsd:decimal",
          },
        }
      end

      #
      # Generate JSON-LD context object
      #

      def jsonld_context
        # definition of imported terms in @context
        object = turtle_prefixes

        # definition of local ontology terms
        pfx = "sos:"

        # definition of class in @context
        sos_class.each do |term|
          object[term] = {}
          object[term]["@id"] = pfx + term
          object[term]["@type"] = "@id"
        end

        # definition of object properties in @context
        sos_object_properties.each do |term|
          object[term] = {}
          object[term]["@id"] = pfx + term
          object[term]["@type"] = "@id"
        end

        sos_data_properties_string.each do |term|
          object[term] = {}
          object[term]["@id"] = pfx + term
          object[term]["@type"] = "http://www.w3.org/2001/XMLSchema#string"
        end

        sos_data_properties_integer.each do |term|
          object[term] = {}
          object[term]["@id"] = pfx + term
          object[term]["@type"] = "http://www.w3.org/2001/XMLSchema#integer"
        end

        sos_data_properties_float.each do |term|
          object[term] = {}
          object[term]["@id"] = pfx + term
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
          "BaseRatio",
          "SequenceReadAmount",
          "SequenceReadRatio",
          "SequenceReadLength",
          "SequenceDuplicationLevel",
          "nContent",
          "percentGC",
          "medianBaseCallQuality",
          "meanBaseCallQuality",
          "totalSequences",
          "filteredSequences",
          "minimumSequenceLength",
          "maxSequenceLength",
          "meanSequenceLength",
          "medianSequenceLength",
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
