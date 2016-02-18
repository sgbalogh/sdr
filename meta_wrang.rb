require 'json'
require 'fileutils'


input_dir = '/Users/sgb334/Documents/metadata_experiment/handle/2451'
output_dir = '/Users/sgb334/Documents/metadata_experiment/output/'

Dir.chdir(input_dir)
directory = Dir.entries(".")
reject_pile = []

directory.each do |record|
  unless record.include? "."

    file = File.read('/Users/sgb334/Documents/metadata_experiment/handle/2451/' + record + '/geoblacklight.json')
    data_hash = JSON.parse(file)

    puts data_hash["dc_identifier_s"]

    # Begin logic for making alterations
    if data_hash["dct_references_s"].include? "nyusdr.net"
      data_hash["dct_references_s"].gsub! "nyusdr.net", "geo.nyu.edu"
    end

    if data_hash["dct_references_s"].include? "http://maps-public.geo.nyu.edu"
      data_hash["dct_references_s"].gsub! "http://maps-public.geo.nyu.edu", "https://maps-public.geo.nyu.edu"
    end

    if data_hash["dct_references_s"].include? "http://maps-restricted.geo.nyu.edu"
      data_hash["dct_references_s"].gsub! "http://maps-restricted.geo.nyu.edu", "https://maps-restricted.geo.nyu.edu"
    end


    # Create the directory to write the resulting file
    dirname = output_dir + record
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end

    # Write the file
    File.open(output_dir + record + '/geoblacklight.json', 'w') do |f|
      f.write(JSON.pretty_generate(data_hash))
    end

  else
    reject_pile << record
  end

end

puts reject_pile