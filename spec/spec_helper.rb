$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bio-fastqc'

class Array
	def depth
		map {|element| element.depth + 1 }.max
	end
end
