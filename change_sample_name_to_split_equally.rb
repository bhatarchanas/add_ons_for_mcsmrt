require 'trollop'

opts = Trollop::options do
	opt :allreadsfile, "File with all the reads and info, the one which needs sample name to be fixed", :type => :string, :short => "-i"
	opt :header, "Answer in yes or no for if the file has a header or not", :type => :string, :short => "-h"
	opt :outfile, "Output file with fixed sample name", :type => :string, :short => "-o"
end
#puts opts
#reads_file = File.open("reads_table_diffs_centroids.tsv", "r")
#out_file = File.open("reads_table_diffs_centroids_2.tsv", "w")

abort("!!!!The all reads file does not exist!!!!") if !File.exists?(opts[:primerfile])

all_reads_file = Bio::FlatFile.auto(opts[:allreadsfile], "r") 
out_file = File.open(opts[:outfile], "w")
header_state = opts[:header]

all_reads_file.each_with_index do |line, index|
	if header_state == "yes" and index == 0
		out_file.puts(line)
	else
		line_split = line.split("\t")
		#puts line_split
		sample_name = line_split[2] # change this to the index of the sample name column
		#puts sample_name
		sample_name_split = sample_name.split("_")
		if sample_name_split.size == 5
			out_file.puts(line)
		else
			sample_name = sample_name_split[0..1].join("_")+"_nothum_"+sample_name_split[2..3].join("_")
			out_file.puts(line_split[0..1].join("\t")+"\t"+sample_name+"\t"+line_split[3..-1].join("\t"))
		end
	end
end