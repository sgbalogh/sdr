require 'json'
require 'CSV'
require 'find'

auth_token = ''
csv_output = ''

public_req = `curl -H "rest-dspace-token: #{auth_token}" https://archive.nyu.edu/rest/collections/651/items?limit=1000`
public_documents = JSON.parse(public_req)

private_req = `curl -H "rest-dspace-token: #{auth_token}" https://archive.nyu.edu/rest/collections/652/items?limit=400`
private_documents = JSON.parse(private_req)

fda_directory = [] # To hold all documents from either two FDA collections

public_documents.each do |doc|
  hash = {:name => doc["name"], :id => doc["id"], :rights => "Public", :handle => doc["handle"], :slug => "nyu_#{doc["handle"].gsub('/','_')}", :expected_primary_bitstream => "nyu_#{doc["handle"].gsub('/','_')}.zip", :primary_bitstream_id => nil, :matching_gb_record => nil }
  fda_directory << hash
end

private_documents.each do |doc|
  hash = {:name => doc["name"], :id => doc["id"], :rights => "Restricted", :handle => doc["handle"], :slug => "nyu_#{doc["handle"].gsub('/','_')}", :expected_primary_bitstream => "nyu_#{doc["handle"].gsub('/','_')}.zip", :primary_bitstream_id => nil, :matching_gb_record => nil  }
  fda_directory << hash
end

total_hash = {}

fda_directory.each do |document|
  total_hash[document[:slug]] = document
end


orig_bitstream_upload_paths = []
  Find.find('/Users/sgb334/Documents/dspace_rest_API_scraper/bitstream_upload/orig/') do |path|
    orig_bitstream_upload_paths << path if path =~ /.*\.(zip)$/i
  end

wgs84_bitstream_upload_paths = []
  Find.find('/Users/sgb334/Documents/dspace_rest_API_scraper/bitstream_upload/wgs84/') do |path|
    wgs84_bitstream_upload_paths << path if path =~ /.*\.(zip)$/i
  end

orig_bitstream_upload_paths.each do |bitstream_path|
  slug = File.basename(bitstream_path,".*")
  dest_item = total_hash[slug][:id]
  req = `curl -H 'rest-dspace-token: #{auth_token}' -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST https://archive.nyu.edu/rest/items/#{dest_item}/bitstreams?name=#{slug}.zip -T '#{bitstream_path}'`
end

wgs84_bitstream_upload_paths.each do |bitstream_path|
  slug = File.basename(bitstream_path,".*").gsub('_WGS84','')
  dest_item = total_hash[slug][:id]
  req = `curl -H 'rest-dspace-token: #{auth_token}' -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST https://archive.nyu.edu/rest/items/#{dest_item}/bitstreams?name=#{slug}_WGS84.zip -T '#{bitstream_path}'`
end
