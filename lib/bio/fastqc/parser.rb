# -*- coding: utf-8 -*-

module Bio
  module FastQC
    class Parser
      def initialize(fastqc_data_txt)
        @data = fastqc_data_txt
        @object = parse(@data)
        @base = self.basic_statistics
      end

      def parse(data)
        modules = data.split(">>END_MODULE\n")
        modules.map do |node|
          lines = node.split("\n")
          rm_header = lines.map do |line|
            if line !~ /^\#/ || line =~ /^#Total Duplicate Percentage/
              line.split("\t")
            end
          end
          rm_header.compact
        end
      end

      def fastqc_version
        @data.split("\n").first.split("\t").last
      end

      def basic_statistics
        Hash[*@object.select{|a| a.first.first == ">>Basic Statistics" }.flatten]
      end

      def filename
        @base["Filename"]
      end

      def file_type
        @base["File type"]
      end

      def encoding
        @base["Encoding"]
      end

      def total_sequences
        @base["Total Sequences"].to_i
      end

      def filtered_sequences
        @base["Filtered Sequences"].to_i
      end

      def sequence_length
        @base["Sequence length"]
      end

      def min_length
        l = @base["Sequence length"]
        if l =~ /\d-\d/
          l.sub(/-\d+$/,"").to_i
        else
          l.to_i
        end
      end

      def max_length
        l = @base["Sequence length"]
        if l =~ /\d-\d/
          l.sub(/^\d+-/,"").to_i
        else
          l.to_i
        end
      end

      def percent_gc
        @base["%GC"].to_i
      end

      def per_base_sequence_quality
        node = @object.select{|a| a.first.first == ">>Per base sequence quality" }.first
        node.select{|n| n.first != ">>Per base sequence quality" } if node
      end

      ## Custom module: overall mean base call quality indicator
      def overall_mean_quality_score
        per_base = self.per_base_sequence_quality
        if per_base
          v = per_base.map{|c| (10**(c[1].to_f/-10)).to_f }
          -10 * Math.log10(v.reduce(:+) / v.size)
        end
      end

      ## Custom module: overall median base call quality indicator
      def overall_median_quality_score
        per_base = self.per_base_sequence_quality
        if per_base
          v = per_base.map{|c| (10**(c[2].to_f/-10)).to_f }
          -10 * Math.log10(v.reduce(:+) / v.size)
        end
      end

      def per_tile_sequence_quality
        node = @object.select{|a| a.first.first == ">>Per tile sequence quality" }.first
        node.select{|n| n.first != ">>Per tile sequence quality" } if node
      end

      def per_sequence_quality_scores
        node = @object.select{|a| a.first.first == ">>Per sequence quality scores" }.first
        node.select{|n| n.first != ">>Per sequence quality scores" } if node
      end

      def per_base_sequence_content
        node = @object.select{|a| a.first.first == ">>Per base sequence content" }.first
        node.select{|n| n.first != ">>Per base sequence content" } if node
      end

      def per_sequence_gc_content
        node = @object.select{|a| a.first.first == ">>Per sequence GC content" }.first
        node.select{|n| n.first != ">>Per sequence GC content" } if node
      end

      def per_sequence_gc_content
        node = @object.select{|a| a.first.first == ">>Per sequence GC content" }.first
        node.select{|n| n.first != ">>Per sequence GC content" } if node
      end

      def per_base_n_content
        node = @object.select{|a| a.first.first == ">>Per base N content" }.first
        node.select{|n| n.first != ">>Per base N content" } if node
      end

      ## Custom module: overall N content
      def overall_n_content
        per_base = self.per_base_n_content
        if per_base
          v = per_base.map{|c| c[1].to_f }
          v.reduce(:+) / v.size
        end
      end

      def sequence_length_distribution
        node = @object.select{|a| a.first.first == ">>Sequence Length Distribution" }.first
        node.select{|n| n.first != ">>Sequence Length Distribution" } if node
      end

      ## Custom module: mean sequence length calculated from distribution
      def mean_sequence_length
        distribution = self.sequence_length_distribution
        if distribution
          sum = distribution.map do |length_count|
            length = length_count[0]
            count = length_count[1].to_f
            if length =~ /\d-\d/
              f = length.sub(/-\d+$/,"").to_i
              b = length.sub(/^\d+-/,"").to_i
              mean = (f + b) / 2
              mean * count
            else
              length.to_i * count
            end
          end
          sum.reduce(:+) / self.total_sequences
        end
      end

      ## Custom module: median sequence length calculated from distribution
      def median_sequence_length
        distribution = self.sequence_length_distribution
        if distribution
          array = distribution.map do |length_count|
            length = length_count[0]
            count = length_count[1].to_i
            if length =~ /\d-\d/
              f = length.sub(/-\d+$/,"").to_i
              b = length.sub(/^\d+-/,"").to_i
              mean = (f + b) / 2
              [mean.to_f] * count
            else
              [length.to_f] * count
            end
          end
          sorted = array.flatten.sort
          quot = sorted.size / 2
          if !sorted.size.even?
            sorted[quot]
          else
            f = sorted[quot]
            b = sorted[quot - 1]
            (f + b) / 2
          end
        end
      end

      def sequence_duplication_levels
        node = @object.select{|a| a.first.first == ">>Sequence Duplication Levels" }.first
        if node
          node.shift(3)
          node
        end
      end

      def total_duplicate_percentage
        node = @object.select{|a| a.first.first == ">>Sequence Duplication Levels" }.first
        node.select{|n| n.first == "\#Total Duplicate Percentage" }.flatten[1].to_f if node
      end

      def overrepresented_sequences
        node = @object.select{|a| a.first.first == ">>Overrepresented sequences" }.first
        node.select{|n| n.first != ">>Overrepresented sequences" } if node
      end

      def adapter_content
        node = @object.select{|a| a.first.first == ">>Adapter Content" }.first
        node.select{|n| n.first != ">>Adapter Content" } if node
      end

      def kmer_content
        node = @object.select{|a| a.first.first == ">>Kmer Content" }.first
        node.select{|n| n.first != ">>Kmer Content" } if node
      end

      def summary
        {
          fastqc_version: self.fastqc_version,
          filename: self.filename,
          file_type: self.file_type,
          encoding: self.encoding,
          total_sequences: self.total_sequences,
          filtered_sequences: self.filtered_sequences,
          sequence_length: self.sequence_length,
          percent_gc: self.percent_gc,
          per_base_sequence_quality: self.per_base_sequence_quality,
          per_tile_sequence_quality: self.per_tile_sequence_quality,
          per_sequence_quality_scores: self.per_sequence_quality_scores,
          per_base_sequence_content: self.per_base_sequence_content,
          per_sequence_gc_content: self.per_sequence_gc_content,
          per_base_n_content: self.per_base_n_content,
          sequence_length_distribution: self.sequence_length_distribution,
          total_duplicate_percentage: self.total_duplicate_percentage,
          sequence_duplication_levels: self.sequence_duplication_levels,
          overrepresented_sequences: self.overrepresented_sequences,
          adapter_content: self.adapter_content,
          kmer_content: self.kmer_content,
          min_length: self.min_length,
          max_length: self.max_length,
          overall_mean_quality_score: self.overall_mean_quality_score,
          overall_median_quality_score: self.overall_median_quality_score,
          overall_n_content: self.overall_n_content,
          mean_sequence_length: self.mean_sequence_length,
          median_sequence_length: self.median_sequence_length,
        }
      end
    end
  end
end
