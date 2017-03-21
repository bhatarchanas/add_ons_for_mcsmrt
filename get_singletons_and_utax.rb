require 'trollop'
require 'bio'

#ruby ../mcsmrt_mod/parse_all_info_file.rb -a all_bc_reads_info_first_few_lines.txt -o parsed_all_bc_reads_info.txt

opts = Trollop::options do
	opt :allreadsfile, "File with all the reads", :type => :string, :short => "-r"
  	opt :allinfofile, "File with all the reads and information regarding each of it", :type => :string, :short => "-a"
  	opt :outfile, "Output file with stats from all info file", :type => :string, :short => "-o"
end

all_reads_file = Bio::FlatFile.auto(opts[:allreadsfile], "r")
all_info_file = File.open(opts[:allinfofile], "r")
out_file = File.open(opts[:outfile], "w")

read_name_array = []
all_info_file.each do |line|
	line_split = line.split("\t")
	read_name = line_split[0]
	note = line_split[-2]
	#puts note
	if note == "forward_singleton" or note == "reverse_singleton"
		read_name_array.push(read_name)
	end
end

all_reads_file.each do |entry|
	#puts entry.definition
	read_def = entry.definition.split(";")[0]
	if read_name_array.include?(read_def)
		out_file.puts(">#{read_def}")
		out_file.puts(entry.naseq.upcase)
	end
end