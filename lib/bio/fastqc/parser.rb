# -*- coding: utf-8 -*-

module Bio
  module FastQC
    class Parser
      def initialize(fastqc_data_txt)
        @data = fastqc_data_txt
        @module_results = parse_modules
        @basic_statistics = basic_statistics
      end

      def parse_modules
        @data.split(">>END_MODULE\n").map do |mod|
          mod.split("\n").map{|line| line.split("\t") }
        end
      end

      #
      # Basic Statistics module
      #

      def basic_statistics
        Hash[*@module_results[0].flatten]
      end

      def fastqc_version # software version of FastQC
        @basic_statistics["##FastQC"]
      end

      def filename # input filename for FastQC program
        @basic_statistics["Filename"]
      end

      def file_type # input file type
        @basic_statistics["File type"]
      end

      def encoding # quality encoding method for input file type
        @basic_statistics["Encoding"]
      end

      def total_sequences # total number of sequence reads
        @basic_statistics["Total Sequences"].to_i
      end

      def sequences_flagged_as_poor_quality # number of sequence reads flagged as poor quality
        @basic_statistics["Sequences flagged as poor quality"].to_i
      end

      def filtered_sequences # number of sequence reads filtered out
        @basic_statistics["Filtered Sequences"].to_i
      end

      def sequence_length # store as string: can be range
        @basic_statistics["Sequence length"]
      end

      def percent_gc # overall percentage of GC content
        @basic_statistics["%GC"].to_f
      end

      #
      # Other modules
      #

      def get_module_matrix(module_name, num_of_header_rows)
        mod = @module_results.select{|m| m[0][0] == ">>#{module_name}" }[0]
        if mod
          mod.shift(num_of_header_rows)
          mod
        end
      end

      def per_base_sequence_quality
        get_module_matrix("Per base sequence quality", 1)
      end

      def per_tile_sequence_quality
        get_module_matrix("Per tile sequence quality", 1)
      end

      def per_sequence_quality_scores
        get_module_matrix("Per sequence quality scores", 1)
      end

      def per_base_sequence_content
        get_module_matrix("Per base sequence content", 1)
      end

      def per_sequence_gc_content
        get_module_matrix("Per sequence GC content", 1)
      end

      def per_base_n_content
        get_module_matrix("Per base N content", 1)
      end

      def sequence_length_distribution
        get_module_matrix("Sequence Length Distribution", 1)
      end

      def total_duplicate_percentage
        get_module_matrix("Sequence Duplication Levels", 1)[0][1].to_f
      end

      def sequence_duplication_levels
        get_module_matrix("Sequence Duplication Levels", 2)
      end

      def overrepresented_sequences
        get_module_matrix("Overrepresented sequences", 1)
      end

      def adapter_content
        get_module_matrix("Adapter Content", 1)
      end

      def kmer_content
        get_module_matrix("Kmer Content", 1)
      end

      #
      # Custom modules
      #

      def min_length
        sequence_length.sub(/-\d+$/,"").to_i
      end

      def max_length
        sequence_length.sub(/^\d+-/,"").to_i
      end

      def per_base_quality_column(mean_or_median)
        case mean_or_median
        when :mean
          1
        when :median
          2
        end
      end

      def overall_quality_score(mean_or_median)
        per_base = per_base_sequence_quality
        per_base.shift # drop header
        column = per_base_quality_column(mean_or_median)
        v = per_base.map do |row|
          (10**(row[column].to_f / -10)).to_f
        end
        -10 * Math.log10(v.reduce(:+) / v.size)
      end

      def overall_mean_quality_score
        overall_quality_score(:mean)
      end

      def overall_median_quality_score
        overall_quality_score(:median)
      end

      def overall_n_content
        per_base = per_base_n_content
        v = per_base.map{|c| c[1].to_f }
        v.reduce(:+) / v.size
      end

      def mean_sequence_length
        dist = sequence_length_distribution
        dist.shift # drop column header
        if dist.size == 1
          dist[0][0].to_f
        else
          sum = dist.map do |length_count|
            l = length_count[0]
            c  = length_count[1].to_f
            if l =~ /\d-\d/
              ((l.sub(/-\d+$/,"").to_f + l.sub(/^\d+-/,"").to_f) / 2 ) * c
            else
              l.to_i * c
            end
          end
          sum.reduce(:+) / sum.size
        end
      end

      def median_sequence_length
        dist = sequence_length_distribution
        dist.shift # drop column header
        if dist.size == 1
          dist[0][0].to_f
        else
          array = dist.map do |length_count|
            l = length_count[0]
            c = length_count[1].to_f
            c.times.map{ l }
          end
          median(array.flatten)
        end
      end

      def median(array)
        a = array.dup
        k = array.size / 2
        loop do
          pivot = a.delete_at(rand(a.size))
          left, right = a.partition{|x| x < pivot }
          if k == left.length
            return pivot
          elsif k < left.length
            a = left
          else
            k = k - left.length - 1
            a = right
          end
        end
      end

      def summary
        parse
      end

      def parse
        {
          fastqc_version: fastqc_version,
          filename: filename,
          file_type: file_type,
          encoding: encoding,
          total_sequences: total_sequences,
          sequences_flagged_as_poor_quality: sequences_flagged_as_poor_quality,
          filtered_sequences: filtered_sequences,
          sequence_length: sequence_length,
          percent_gc: percent_gc,
          per_base_sequence_quality: per_base_sequence_quality,
          per_tile_sequence_quality: per_tile_sequence_quality,
          per_sequence_quality_scores: per_sequence_quality_scores,
          per_base_sequence_content: per_base_sequence_content,
          per_sequence_gc_content: per_sequence_gc_content,
          per_base_n_content: per_base_n_content,
          sequence_length_distribution: sequence_length_distribution,
          total_duplicate_percentage: total_duplicate_percentage,
          sequence_duplication_levels: sequence_duplication_levels,
          overrepresented_sequences: overrepresented_sequences,
          adapter_content: adapter_content,
          kmer_content: kmer_content,
          min_length: min_length,
          max_length: max_length,
          overall_mean_quality_score: overall_mean_quality_score,
          overall_median_quality_score: overall_median_quality_score,
          overall_n_content: overall_n_content,
          mean_sequence_length: mean_sequence_length,
          median_sequence_length: median_sequence_length,
        }
      end
    end
  end
end
