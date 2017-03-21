require 'trollop'

#ruby ../mcsmrt_mod/parse_all_info_file.rb -a all_bc_reads_info_first_few_lines.txt -o parsed_all_bc_reads_info.txt

opts = Trollop::options do
  	opt :allinfofile, "File with all the reads and information regarding each of it", :type => :string, :short => "-a"
  	opt :outfile, "Output file with stats from all info file", :type => :string, :short => "-o"
end

all_info_file = File.open(opts[:allinfofile], "r")
out_file = File.open(opts[:outfile], "w")

parsed_hash = {}
f_match_count = 0
r_match_count = 0

all_info_file.each_with_index do |line, index|
	if index == 0
		header = line
	else
		line_split = line.split("\t")
		basename = line_split[1]
		length_pretrim = line_split[7].to_i
		host_map = line_split[9]
		f_match = line_split[10]
		r_match = line_split[11]
		singleton_match = line_split[-1]
		#puts f_match, r_match, singleton_match
		#puts basename, length_pretrim, host_map

		if f_match == "true" and r_match == "false"
			f_match_count += 1
		end
		if r_match == "true" and f_match == "false"
			r_match_count += 1
		end

		if parsed_hash.key?(basename)
			parsed_hash[basename][0] += 1
			if length_pretrim >= 500 and length_pretrim <= 2000
				parsed_hash[basename][1] += 1
			end
			if host_map == "false"
				parsed_hash[basename][2] += 1
			end
			if f_match == "true" and r_match == "true"
				parsed_hash[basename][3] += 1
			elsif f_match == "true" or r_match == "true"
				if singleton_match == "true"
					parsed_hash[basename][3] += 1
				end
			end
		else
			parsed_hash[basename] = [0, 0, 0, 0]
			parsed_hash[basename][0] = 1
			if length_pretrim >= 500 and length_pretrim <= 2000
				parsed_hash[basename][1] = 1
			end
			if host_map == "false"
				parsed_hash[basename][2] = 1
			end
			if f_match == "true" and r_match == "true"
				parsed_hash[basename][3] = 1
			elsif f_match == "true" or r_match == "true"
				if singleton_match == "true"
					parsed_hash[basename][3] = 1
				end
			end
		end
	end
end

#puts parsed_hash
#puts f_match_count, r_match_count


parsed_hash.each do |key, value|
	#puts key, value
	passed_size_lift = value[0] - value[1]
	remains_after_size_filt = value[0] - passed_size_lift
	remains_after_host_filt = remains_after_size_filt - (value[0] - value[2])
	remains_after_primer_filt = remains_after_size_filt - (value[0] - value[3])
	out_file.puts("#{key}\t#{value[0]}\t#{remains_after_size_filt}\t#{remains_after_host_filt}\t#{remains_after_primer_filt}")
end