require 'json'
require 'CSV'

auth_token = ''
csv_output = ''

container_data = {
  :metadata=>[
    {
      :key=>"dc.contributor.author",
      :value=>"Balogh, Stephen"},
    {
      :key=>"dc.description",
      :language=>"en_US",
      :value=>"This record was created to mint a handle. It does not yet contain any content."},
    {
      :key=>"dc.description.abstract",
      :language=>"en_US",
      :value=>"This record was created to mint a handle. It does not yet contain any content."},
    {
      :key=>"dc.title",
      :language=>"en_US",
      :value=>"Empty Container Document"}
  ]
}

handle_directory = []

data_string = JSON.generate(container_data)
collections = {
  :public => 651,
  :restricted => 652
}

(1..5).each do |i|
  req = `curl -H 'rest-dspace-token: #{auth_token}' -H 'Content-Type: application/json' -H 'Accept: application/json' --data '#{data_string}' https://archive.nyu.edu/rest/collections/#{collections[:restricted]}/items`
  response = JSON.parse(req)
  handle_directory << response
end


CSV.open(csv_output, "wb") do |csv|
  csv << ["FDA ID", "Handle", "Slug", "URL"]
  handle_directory.each do |document|
    csv << [document["id"], document["handle"], "nyu_#{document["handle"].gsub('/','_')}", "http://hdl.handle.net/#{document["handle"]}"]
  end
end
