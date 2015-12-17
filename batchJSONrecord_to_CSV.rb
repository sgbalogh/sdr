## Script for converting GeoBlacklight JSON records (in batch Omeka generated reports) into lines in a CSV document
## Stephen Balogh, December 16, 2015
## sgb334@nyu.edu

require 'json'

## Locations of batch JSON reports
filedb = ["/Users/sgb334/Documents/URI_record_work/india_records_export.json", "/Users/sgb334/Documents/URI_record_work/withURI_nov23_15.json", "/Users/sgb334/Documents/URI_record_work/pilot_uri.json", "/Users/sgb334/Documents/URI_record_work/china_uri.json"]

## List of elements to scrape from JSON records (order must correspond to headers, printed below)
elementsArray = ["uuid", "layer_slug_s", "dct_spatial_sm", "layer_id_s", "dc_title_s", "dc_description_s", "dc_language_s", "dct_isPartOf_sm", "layer_geom_type_s", "dc_format_s", "dc_rights_s", "dc_type_s", "dc_creator_sm", "dc_publisher_s", "dc_subject_sm", "dct_temporal_sm", "dct_issued_s", "georss_box_s", "georss_polygon_s", "solr_geom", "dc_relation_sm"]

## Prints headers for first line of CSV document
puts "Archive Link,Slug,Spatial Subject,GeoServer Layer,Title,Description,Language,Set (isPartOf),Geometry Type,Format,Rights,Type,Creator,Publisher,Subjects (LOC),Temporal,Date Issued,GeoRSS,GeoRSS Polygon,Solr Geometry,GeoNames Relations"

f = 0
while f < filedb.count do

  currentFile = filedb[f]
  string = File.read(currentFile)
  doc = JSON.parse(string)

  records = doc.count

  i = 1
  while i <= records do
    output = "output #{i}"
    record = doc["#{output}"][0]

    activeString = ""
    t = 0
    while t < elementsArray.count do
      activeString += "\""
      if record.key?(elementsArray[t])
        if record[elementsArray[t]].kind_of?(Array) then
          if (record[elementsArray[t]].count > 0) then
            activeString += record[elementsArray[t]].join(";")
          else
            activeString += record[elementsArray[t]].join(";")
          end
        else
          activeString += record[elementsArray[t]]
        end
      else
        activeString += "NONE"
      end
      activeString += "\","

      t += 1
    end # End loop through elements listed in elementsArray
    puts activeString
    i += 1

  end ## End loop through each individual record
  f += 1

end ## End loop through each "batch export" document