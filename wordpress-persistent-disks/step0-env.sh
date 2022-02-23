PROJECT_ID=wordpress-on-gke-342003
WORKING_DIR=$(pwd)
CLUSTER_NAME=wordpress-persistent-disk
INSTANCE_NAME=mysql-wordpress-instance


gcloud config set compute/zone us-west1-a

# WP pwd: nOo^(j&GzEasBh2thT