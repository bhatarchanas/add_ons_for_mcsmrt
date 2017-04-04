require 'bio'
require 'trollop'

opts = Trollop::options do
  opt :otufile, "Fasta file with all the OTUs", :type => :string, :short => "-u"
  opt :upfile, "File from uparse", :type => :string, :short => "-p"
  opt :fafile, "Fata file with all the sequences", :type => :string, :short => "-a"
end

otu_file = Bio::FlatFile.auto(opts[:otufile], "r")
up_file = opts[:upfile]
fa_file = opts[:fafile]

otu_list = []
otu_file.each do |entry|
  otu_list.push(entry.definition.split(";")[0])
  #each_otu_file = File.open("#{entry.definition.split(";")[0]}.fasta", "w")
  #each_otu_file.puts(entry)
end
#puts otu_list

#`ruby convert_fastq_to_fasta.rb -q all_ee1_oriented_filtered.fastq -a all_ee1_oriented_filtered.fasta` ##### Uncomment if you don't have fasta file 
`samtools faidx #{fa_file}`

(0..otu_list.size-1).each do |otu|
  puts "#{otu_list[otu]}"
  `grep -P "#{otu_list[otu]}$" #{up_file} | cut -f1 | cut -d ";" -f1 > #{otu_list[otu]}_headers.txt`
  `xargs samtools faidx #{fa_file} < #{otu_list[otu]}_headers.txt > #{otu_list[otu]}_eefilt_subset.fasta`
  #`usearch -ublast #{otu_list[otu]}_subset.fasta -db all_ee1_OTU.fasta -top_hit_only -id 0.9 -blast6out #{otu_list[otu]}_eefilt_blast.txt -strand both -evalue 0.01 -threads 15`
end
