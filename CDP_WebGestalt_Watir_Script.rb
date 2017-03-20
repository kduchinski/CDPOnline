#CDP_WebGestalt_Watir_Script.rb
#Created by: Hassam Solano-Morel, Paul Anderson
#Updated 3.20.2017 by Katherine Duchinski


require 'watir-webdriver'
require 'headless'
require "open-uri"
require "json"
Watir.default_timeout = 300

file = File.read("#{Dir.pwd}/users/" + ARGV[0] +"/userData.txt")
userData = JSON.parse(file)


DOWNLOAD_PATH = "#{Dir.pwd}/users/" + ARGV[0]+ "/webGResults.tsv" #REPLACE text.tsv w/ "JSON:jobID"
ENTREZ_IDS = userData['entrezIDs']



headless = Headless.new
headless.start
b = Watir::Browser.start 'http://www.webgestalt.org/option.php'

puts b.title#*

#Paste in entrez ids 
b.select_list(:name => 'organism').select 'hsapiens'
# Options
#<option>athaliana</option>
#<option>btaurus</option>
#<option>celegans</option>
#<option>cfamiliaris</option>
#<option>dmelanogaster</option>	
#<option>drerio</option>
#<option>ggallus</option>
#<option>hsapiens</option>
#<option>mmusculus</option>
#<option>rnorvegicus</option>
#<option>scerevisiae</option>
#<option>sscrofa</option>
#<option>others</option>
b.select_list(:name => 'method').select 'Overrepresentation Enrichment Analysis (ORA)'
# Options
#<option>Overrepresentation Enrichment Analyis (ORA)</option>
#<option>Gene Set Enrichment Analyis (GSEA)</option>
#<option>Network Topology-Based Analyis (NTA)</option>

enrichment = userData['enrichmentType']

case enrichment 
when "KEGG"
	type = 'pathway'
	enrichment = 'KEGG'
when "TF"
	type = 'network'
	enrichment = 'Transcription_Factor_target'
when "WIKI"
	type = 'pathway'
	enrichment = 'Wikipathway'

end 

b.select_list(:name => 'databaseClass').select type
b.select_list(:name => 'databaseName').select enrichment

sleep(2)
b.select_list(:name => 'idtype').select 'entrezgene'
b.textarea(:name => 'pastefile').set ENTREZ_IDS.join("\n")

puts b.title#*

b.select_list(:name => "refset").select "genome_protein-coding"#"JSON:refSet"
b.button(:value => "Advanced Parameters").click
b.textarea(:name => "min").set userData['minGenes'] #Minimum Number of genes in category
b.radio(:value => 'FDR').set
b.textarea(:name => "cutoff").set userData['cutoff']#"JSON:sigLevel"

b.button(:value => "Submit").click


b.windows.last.use #Previous action opens a new window


#Download TSV Results 
File.open(DOWNLOAD_PATH, 'w') do |file|
  file.write open(b.link(:text => "Export TSV Only").href).read
end



b.close
headless.destroy


userData['WG_file_path'] = DOWNLOAD_PATH

puts userData.to_json

File.open("#{Dir.pwd}/users/" + ARGV[0] +"/userData.txt",'w') do |f|
  f << userData.to_json
end







