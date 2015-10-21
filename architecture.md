##Architecture Model
####Discrete services

| Service  | Endpoint  | Access  |
| ----------------- |:-------------:| -----:|
| **GeoBlacklight**| `geoblacklight.namespace`| Accessible to all|   
| **Solr**  |`solr.namespace`| Only accessible to GeoBlacklight (for executing queries) and Omeka (for GeoCombine ingest) servers
|**GeoServer:** Public| `maps-public.namespace` | Accessible to all |
| **GeoServer:** Restricted| `maps-restricted.namespace` | Accessible within VPC and NYU IP address ranges (off-campus can connect via EZproxy)|
| **Omeka / Record Collection**  | `submit.namespace`| Accessible to all

####Geospatial datastores
| Service  | Endpoint  | Data type | Access  |
| ----------------- |:-------------:| :-----:| -----: |
| **PostGIS** (PostgreSQL) **Database**  | AWS managed | Vector |Only read/write accessible within VPC; read-only accessible from NYU IP range
| **S3 Bucket**  | AWS managed | Raster | Only accessible within VPC; sync-point for GeoServer instances
