##Sync Behaviors
###GeoServer data (maps-public, maps-restricted)

*GeoServer home path*: `/var/lib/tomcat7/webapps/geoserver`

*Raster data directory*: `/var/lib/rastersync` (this needs to be explicitly set in GeoServer preferences)

Nightly(/weekly) actions:

1. Commit changes in GeoServer home path to local git repo (push to private?)
2. Tarball home path with git repo, and use S3 sync to deposit nightly/weekly backup in S3 bucket: `geoserver-maps-public` or `geoserver-maps-restricted`
3. Check for updates in both local raster data directory and corresponding S3 bucket; run S3 (no delete mode) sync to update either; raster stored in `assets/raster-maps-public` or `assets/raster-maps-restricted`
4. Export xml representation of current GeoServer features, workspaces, and datastores (using curl and GeoServer's HTTP API), push to private git repo?

Start-up from AMI actions:

1. `aws s3 sync` (or possibly `git clone`, if private git VCS used) the corresponding GeoServer home path and raster data directory from most current state in S3
2. `git commit -am` after sync


###Omeka metadata (submit)

###Vector data backups (submit / RDS)


