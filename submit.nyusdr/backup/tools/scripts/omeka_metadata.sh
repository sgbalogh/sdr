now=`date +%Y-%m-%d_%H.%M.%S`

cd /home/ubuntu/backup/omeka_metadata/nightly/mysql_omeka_csv
for table in $(mysql  -u USERNAME -pPASSWORD omeka -sN -e "SHOW TABLES;"); do
	mysql -B -u USERNAME -pPASSWORD omeka -h localhost -e "SELECT * FROM ${table};" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > $table.csv
done

cd /home/ubuntu/backup/omeka_metadata/nightly/mysql_omeka_sql
mysqldump -u USERNAME -pPASSWORD --single-transaction omeka > omeka.sql

# Use Omekadd (Python tool) to export CSV from local install via Omeka API connection
# https://github.com/wcaleb/omekadd
cd /home/ubuntu/backup/tools/omekadd
python omekacsv.py

for doc in *.csv; do
	cp $doc /home/ubuntu/backup/omeka_metadata/nightly/omeka_csv/$doc
done

cd /home/ubuntu/backup/omeka_metadata/nightly
git commit -am "auto commit ${now}"

cd /home/ubuntu/backup/omeka_metadata
tar cvfz nightly_zip/nightly_zip.tar.gz ./nightly

/usr/local/bin/aws s3 sync /home/ubuntu/backup/omeka_metadata/nightly_zip s3://sdr-assets/omeka_metadata/nightly_zip
# /usr/local/bin/aws s3 sync /home/ubuntu/backup/omeka_metadata/nightly s3://sdr-assets/omeka_metadata/nightly/$now