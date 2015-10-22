#Sync & Backup Behaviors
###GeoServer / raster data (`maps-public.namespace`, `maps-restricted.namespace`)

**GeoServer home path**: `/var/lib/tomcat7/webapps/geoserver`

**Raster data directory**: `/var/lib/rastersync` (this needs to be explicitly set in GeoServer preferences)

Nightly(/weekly) actions:

1. Commit changes in GeoServer home path to local git repo (push to private?)
2. Tarball home path with git repo, and use S3 sync to deposit nightly/weekly backup in S3 bucket: `backup/geoserver-maps-public` or `backup/geoserver-maps-restricted`
3. Check for updates in both local raster data directory and corresponding S3 bucket; run S3 (no delete mode) sync to update either; raster stored in `geospatial-assets/raster-maps-public` or `geospatial-assets/raster-maps-restricted`
4. Export xml representation of current GeoServer features, workspaces, and datastores (using curl and GeoServer's HTTP API), push to private git repo?

Start-up from AMI actions:

1. `aws s3 sync` (or possibly `git clone`, if private git VCS used) the corresponding GeoServer home path and raster data directory from most current state in S3
2. `git commit -am 'Auto Commit, TIMESTAMP'`, `git push` after sync

###Vector data backups (`submit.namespace` / RDS)

* Originals (before reprojection or SQL conversion) can be stored in S3 bucket manually
* RDS deployed with Amazon's redundancy features enabled
* Monthly(?) sync with on-prem HD?

###Omeka metadata (`submit.namespace`)
Nightly(/weekly) actions:

1. SQL dump of Omeka db
2. Generate CSV from metadata fields via API connection using [omekadd](https://github.com/wcaleb/omekadd)
3. Replace previous nightly, `git commit -am 'Auto Commit, TIMESTAMP'`, `git push`
4. `aws s3 sync` to metadata backup bucket

----
###S3 Bucket destination cheatsheet (tentative)
| Bucket Directory  | Sync Context  | Comment  |
| ------------- |:-------------:| -----:|
| `geospatial-assets/raster`     | Synced with local GeoServer raster data dir      |   Always sync additively; when AMI deployed, pull raster data from here 
| `geospatial-assets/vector` |    Synced with directories from staging/scripting environment on EC2:*submit* | essentially just a backup (authority is stored in RDS PostGIS db); only WGS84 projection, SQL versions of datasets
|`backup/maps-public`     | Complete backup of GeoServer home dir (omit datastores) |  |
| `backup/maps-restricted`     | Complete backup of GeoServer home dir (omit datastores)      |  |
| `logs` |    |
| `records/omeka` |  Nightly(/weekly) updates of Omeka metadata content from SQL dumps and CSV export via [omekadd](https://github.com/wcaleb/omekadd) API client |
| `records/geoserver` |  XML reports from nightly `curl` of GeoServer objects |


