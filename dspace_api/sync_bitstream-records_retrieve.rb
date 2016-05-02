require 'json'
require 'CSV'
require 'FileUtils'
require 'find'

## Remember to pull down the most recent changes in the edu.nyu repo before running!

auth_token = ''
output_dir = ''

public_req = `curl -H "rest-dspace-token: #{auth_token}" https://archive.nyu.edu/rest/collections/651/items?limit=1000`
public_documents = JSON.parse(public_req)

private_req = `curl -H "rest-dspace-token: #{auth_token}" https://archive.nyu.edu/rest/collections/652/items?limit=400`
private_documents = JSON.parse(private_req)

fda_directory = [] # To hold all documents from either two FDA collections

public_documents.each do |doc|
  hash = {
      :name => doc["name"],
      :id => doc["id"],
      :rights => "Restricted",
      :handle => doc["handle"],
      :slug => "nyu_#{doc["handle"].gsub('/','_')}",
      :expected_primary_bitstream => "nyu_#{doc["handle"].gsub('/','_')}.zip",
      :primary_bitstream_id => nil,
      :wgs84_bitstream_id => nil,
      :documentation_bitstream_id => nil,
      :matching_gb_record => nil,
      :dd_link => nil,
      :rp_link => nil,
      :doc_link => nil
    }
  fda_directory << hash
end

private_documents.each do |doc|
  hash = {
      :name => doc["name"],
      :id => doc["id"],
      :rights => "Restricted",
      :handle => doc["handle"],
      :slug => "nyu_#{doc["handle"].gsub('/','_')}",
      :expected_primary_bitstream => "nyu_#{doc["handle"].gsub('/','_')}.zip",
      :primary_bitstream_id => nil,
      :wgs84_bitstream_id => nil,
      :documentation_bitstream_id => nil,
      :matching_gb_record => nil,
      :dd_link => nil,
      :rp_link => nil,
      :doc_link => nil
    }
  fda_directory << hash
end

fda_directory.each do |document|
  bitstream_resp = `curl -H "rest-dspace-token: #{auth_token}" https://archive.nyu.edu/rest/items/#{document[:id]}/bitstreams`
  bitstreams = JSON.parse(bitstream_resp)
  bitstreams.each do |bitstream|
    if bitstream["name"] == document[:expected_primary_bitstream]
      document[:primary_bitstream_id] = bitstream["id"]
      document[:dd_link] = "https://archive.nyu.edu/retrieve/#{bitstream["id"]}/#{document[:slug]}.zip"
    elsif bitstream["name"] == "#{document[:slug]}_WGS84.zip"
      document[:primary_bitstream_id] = bitstream["id"]
      document[:rp_link] = "https://archive.nyu.edu/retrieve/#{bitstream["id"]}/#{document[:slug]}_WGS84.zip"
    elsif bitstream["name"] == "#{document[:slug]}_doc.zip"
      document[:documentation_bitstream_id] = bitstream["id"]
      document[:doc_link] = "https://archive.nyu.edu/retrieve/#{bitstream["id"]}/#{document[:slug]}_doc.zip"
    end
  end
end

CSV.open("/Users/sgb334/Documents/dspace_rest_API_scraper/output.csv", "wb") do |csv|
  csv << ["Title", "FDA ID", "Rights", "Handle", "Primary File (Expected)", "Primary Bitstream ID"]
  fda_directory.each do |document|
    csv << [document[:name], document[:id], document[:rights], document[:handle], document[:expected_primary_bitstream], document[:primary_bitstream_id]]
  end
end

total_hash = {}

fda_directory.each do |document|
  total_hash[document[:slug]] = document
end

record_paths = []
  Find.find('/Users/sgb334/git/edu.nyu') do |path|
    record_paths << path if path =~ /.*\.(json)$/i
  end

record_paths.each do |record|
	doc = JSON.parse(File.read(record))
	doc_ref = JSON.parse(doc['dct_references_s'])
	searchkey = doc['layer_slug_s']
	dir_structure = record[26..42]
	dirname = output_dir + dir_structure

	if total_hash[searchkey][:dd_link].nil?
    doc_ref.delete('http://schema.org/downloadUrl')
  else
		doc_ref['http://schema.org/downloadUrl'] = total_hash[searchkey][:dd_link]
		doc['dct_references_s'] = JSON.generate(doc_ref)
	end

	unless File.directory?(dirname)
	  FileUtils.mkdir_p(dirname)
	end

	File.open(output_dir + dir_structure + '/geoblacklight.json', 'w') do |f|
	  f.write(JSON.pretty_generate(doc))
	end
end
