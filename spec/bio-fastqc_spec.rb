require 'spec_helper'

describe Bio::FastQC do
  context "with an example data" do
    before do
      zipfile = File.join(__dir__, "example_fastqc.zip")
      @data = Bio::FastQC::Data.read(zipfile)
    end
    
    it 'extracts data from zip file' do
      expect(@data).not_to be_empty
    end
    
    it 'parses a fastqc data and returns json' do
      p = Bio::FastQC::Parser.new(@data)
      expect(p.summary).not_to be_empty
    end
  end
end
