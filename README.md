# bio-fastqc

[![Build Status](https://secure.travis-ci.org/inutano/bioruby-fastqc.png)](http://travis-ci.org/inutano/bioruby-fastqc)

A ruby parser for [FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) data. 

## Reqruirements

Ruby 2.0 or later

## Installation

```sh
gem install bio-fastqc
```

## Usage

```ruby
require 'bio-fastqc'

# extract data from zipfile
zip_file = "/path/to/data_fastqc.zip"
data = Bio::FastQC::Data.read(zip_file)
parser = Bio::FastQC::Parser.new(data)
parser.summary
```

Parse FastQC data as json format by command line tool:

```sh
$ fastqc-util parse /path/to/data_fastqc.zip
```

## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/inutano/bioruby-fastqc

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

If you use this software, please cite one of

* [BioRuby: bioinformatics software for the Ruby programming language](http://dx.doi.org/10.1093/bioinformatics/btq475)
* [Biogem: an effective tool-based approach for scaling up open source software development in bioinformatics](http://dx.doi.org/10.1093/bioinformatics/bts080)

## Biogems.info

This Biogem is published at (http://biogems.info/index.html#bio-fastqc)

## Copyright

Copyright (c) 2015 Tazro Inutano Ohta. See LICENSE.txt for further details.
