require 'spec_helper'

describe Bio::FastQC do
  context "with an example data" do
    before do
      @zipfile = File.join(__dir__, "example_fastqc.zip")
    end

    describe Bio::FastQC::Data do
      before do
        @data = Bio::FastQC::Data.read(@zipfile)
      end

      describe '#read' do
        it 'returns parsed data from zipfile' do
          expect(@data).not_to be_empty
          expect(@data).not_to be_nil
        end
      end
    end

    describe Bio::FastQC::Parser do
      before do
        @data = Bio::FastQC::Data.read(@zipfile)
        @parser = Bio::FastQC::Parser.new(@data)
      end

      describe '#fastqc_version' do
        it 'returns fastqc version as String' do
          expect(@parser.fastqc_version).to be_instance_of(String)
        end

        it 'does not return empty string' do
          expect(@parser.fastqc_version).not_to be_empty
        end

        it 'does not return nil' do
          expect(@parser.fastqc_version).not_to be_nil
        end
      end

      describe '#filename' do
        it 'returns filename as String' do
          expect(@parser.filename).to be_instance_of(String)
        end

        it 'does not return empty string' do
          expect(@parser.filename).not_to be_empty
        end

        it 'does not return nil' do
          expect(@parser.filename).not_to be_nil
        end
      end

      describe '#file_type' do
        it 'returns file type as String' do
          expect(@parser.file_type).to be_instance_of(String)
        end

        it 'does not return empty string' do
          expect(@parser.file_type).not_to be_empty
        end

        it 'does not return nil' do
          expect(@parser.file_type).not_to be_nil
        end
      end

      describe '#encoding' do
        it 'returns encoding type as String' do
          expect(@parser.encoding).to be_instance_of(String)
        end

        it 'does not return empty string' do
          expect(@parser.encoding).not_to be_empty
        end

        it 'does not return nil' do
          expect(@parser.encoding).not_to be_nil
        end
      end

      describe '#total_sequences' do
        it 'returns total number of sequences as Fixnum' do
          expect(@parser.total_sequences).to be_instance_of(Fixnum)
        end

        it 'returns integer larger than zero' do
          expect(@parser.total_sequences).to be > 0
        end

        it 'does not return nil' do
          expect(@parser.total_sequences).not_to be_nil
        end
      end

      describe '#filtered_sequences' do
        it 'returns number of filtered sequence as Fixnum, can be nil' do
          if @parser.filtered_sequences
            expect(@parser.filtered_sequences).to be_instance_of(Fixnum)
          end
        end
      end

      describe '#sequences_flagged_as_poor_quality' do
        it 'returns number of sequences flagged as poor quality as Fixnum, can be nil' do
          if @parser.sequences_flagged_as_poor_quality
            expect(@parser.sequences_flagged_as_poor_quality).to be_instance_of(Fixnum)
          end
        end
      end

      describe '#sequence_length' do
        it 'returns length of sequence as String' do
          expect(@parser.sequence_length).to be_instance_of(String)
        end

        it 'does not return empty string' do
          expect(@parser.sequence_length).not_to be_empty
        end

        it 'does not return nil' do
          expect(@parser.sequence_length).not_to be_nil
        end
      end

      describe '#percent_gc' do
        it 'returns percentage of GC content as Float' do
          expect(@parser.percent_gc).to be_instance_of(Float)
        end

        it 'does not return nil' do
          expect(@parser.percent_gc).not_to be_nil
        end
      end

      describe '#per_base_sequence_quality' do
        before do
          @value = @parser.per_base_sequence_quality
        end

        it 'returns data frame as Array' do
          expect(@value).to be_instance_of(Array)
        end

        it 'returns an array with depth 2' do
          expect(@value.depth).to eq(2)
        end

        it 'returns an array of an array with 7 elements' do
          sizes = @value.map{|a| a.size }.uniq
          expect(sizes).to eq([7])
        end
      end

      describe '#per_tile_sequence_quality' do
        it 'returns data frame as Array' do
          expect(@parser.per_tile_sequence_quality).to be_instance_of(Array)
        end

        it 'returns array with depth 2' do
          expect(@parser.per_tile_sequence_quality.depth).to eq(2)
        end

        it 'returns an array of an array with 3 elements' do
          sizes = @parser.per_tile_sequence_quality.map{|a| a.size }.uniq
          expect(sizes).to eq([3])
        end
      end

      describe '#per_sequence_quality_scores' do
        it 'returns data frame as Array' do
          expect(@parser.per_sequence_quality_scores).to be_instance_of(Array)
        end

        it 'returns array with depth 2' do
          expect(@parser.per_sequence_quality_scores.depth).to eq(2)
        end

        it 'returns an array of an array with 2 elements' do
          sizes = @parser.per_sequence_quality_scores.map{|a| a.size }.uniq
          expect(sizes).to eq([2])
        end
      end

      describe '#per_base_sequence_content' do
        it 'returns data frame as Array' do
          expect(@parser.per_base_sequence_content).to be_instance_of(Array)
        end

        it 'returns array with depth 2' do
          expect(@parser.per_base_sequence_content.depth).to eq(2)
        end

        it 'returns an array of an array with 5 elements' do
          sizes = @parser.per_base_sequence_content.map{|a| a.size }.uniq
          expect(sizes).to eq([5])
        end
      end

      describe '#per_sequence_gc_content' do
        it 'returns data frame as Array' do
          expect(@parser.per_sequence_gc_content).to be_instance_of(Array)
        end

        it 'returns array with depth 2' do
          expect(@parser.per_sequence_gc_content.depth).to eq(2)
        end

        it 'returns an array of an array with 2 elements' do
          sizes = @parser.per_sequence_gc_content.map{|a| a.size }.uniq
          expect(sizes).to eq([2])
        end
      end

      describe '#per_base_n_content' do
        it 'returns data frame as Array' do
          expect(@parser.per_base_n_content).to be_instance_of(Array)
        end

        it 'returns array with depth 2' do
          expect(@parser.per_base_n_content.depth).to eq(2)
        end

        it 'returns an array of an array with 2 elements' do
          sizes = @parser.per_base_n_content.map{|a| a.size }.uniq
          expect(sizes).to eq([2])
        end
      end

      describe '#sequence_length_distribution' do
        it 'returns data frame as Array' do
          expect(@parser.sequence_length_distribution).to be_instance_of(Array)
        end

        it 'returns array with depth 2' do
          expect(@parser.sequence_length_distribution.depth).to eq(2)
        end

        it 'returns an array of an array with 2 elements' do
          sizes = @parser.sequence_length_distribution.map{|a| a.size }.uniq
          expect(sizes).to eq([2])
        end
      end

      describe '#total_duplicate_percentage' do
        it 'returns duplicate percentage as Float and not empty' do
          expect(@parser.total_duplicate_percentage).to be_instance_of(Float)
        end

        it 'does not returns nil' do
          expect(@parser.total_duplicate_percentage).not_to be_nil
        end
      end

      describe '#sequence_duplication_levels' do
        it 'returns data frame as Array' do
          expect(@parser.sequence_duplication_levels).to be_instance_of(Array)
        end

        it 'returns array with depth 2' do
          expect(@parser.sequence_duplication_levels.depth).to eq(2)
        end

        it 'returns an array of an array with 3 elements' do
          sizes = @parser.sequence_duplication_levels.map{|a| a.size }.uniq
          expect(sizes).to eq([3])
        end
      end

      describe '#overrepresented_sequences' do
        it 'returns data frame as Array' do
          expect(@parser.overrepresented_sequences).to be_instance_of(Array)
        end

        it 'returns array with depth 2' do
          expect(@parser.overrepresented_sequences.depth).to eq(2)
        end

        it 'returns an array of an array with 4 elements' do
          sizes = @parser.overrepresented_sequences.map{|a| a.size }.uniq
          expect(sizes).to eq([4])
        end
      end

      describe '#adapter_content' do
        it 'returns data frame as Array' do
          expect(@parser.adapter_content).to be_instance_of(Array)
        end

        it 'returns array with depth 2' do
          expect(@parser.adapter_content.depth).to eq(2)
        end

        it 'returns an array of an array with 5 elements' do
          sizes = @parser.adapter_content.map{|a| a.size }.uniq
          expect(sizes).to eq([5])
        end
      end

      describe '#kmer_content' do
        it 'returns data frame as Array' do
          expect(@parser.kmer_content).to be_instance_of(Array)
        end

        it 'returns array with depth 2' do
          expect(@parser.kmer_content.depth).to eq(2)
        end

        it 'returns an array of an array with 5 elements' do
          sizes = @parser.kmer_content.map{|a| a.size }.uniq
          expect(sizes).to eq([5])
        end
      end

      describe '#min_length' do
        it 'returns minimum read length as Fixnum and not empty' do
          expect(@parser.min_length).to be_instance_of(Fixnum)
        end

        it 'returns integer larger than zero' do
          expect(@parser.min_length).to be > 0
        end

        it 'does not return nil' do
          expect(@parser.min_length).not_to be_nil
        end
      end

      describe '#max_length' do
        it 'returns maximum read length as Fixnum and not empty' do
          expect(@parser.max_length).to be_instance_of(Fixnum)
        end

        it 'returns integer larger than zero' do
          expect(@parser.max_length).to be > 0
        end

        it 'does not return nil' do
          expect(@parser.max_length).not_to be_nil
        end
      end

      describe '#overall_mean_quality_score' do
        it 'returns overall mean quality score as Float and not empty' do
          expect(@parser.overall_mean_quality_score).to be_instance_of(Float)
        end

        it 'does not return nil' do
          expect(@parser.overall_mean_quality_score).not_to be_nil
        end
      end

      describe '#overall_median_quality_score' do
        it 'returns overall median quality score as Float and not empty' do
          expect(@parser.overall_median_quality_score).to be_instance_of(Float)
        end

        it 'does not return nil' do
          expect(@parser.overall_median_quality_score).not_to be_nil
        end
      end

      describe '#overall_n_content' do
        it 'returns overall N content as Float and not empty' do
          expect(@parser.overall_n_content).to be_instance_of(Float)
        end

        it 'does not return nil' do
          expect(@parser.overall_n_content).not_to be_nil
        end
      end

      describe '#mean_sequence_length' do
        it 'returns mean sequence length from read length distribution as Float and not empty' do
          expect(@parser.mean_sequence_length).to be_instance_of(Float)
        end

        it 'does not return nil' do
          expect(@parser.mean_sequence_length).not_to be_nil
        end
      end

      describe '#median_sequence_length' do
        it 'returns median sequence length from read length distribution as Float and not empty' do
          expect(@parser.median_sequence_length).to be_instance_of(Float)
        end

        it 'does not return nil' do
          expect(@parser.median_sequence_length).not_to be_nil
        end
      end

      describe '#parse' do
        it 'does not return nil' do
          expect(@parser.parse).not_to be_nil
        end

        it 'returns hash' do
          expect(@parser.parse).to be_instance_of(Hash)
        end
      end
    end
  end
end
