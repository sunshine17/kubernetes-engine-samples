PROJECT_ID=wordpress-on-gke-342003
gcloud config set compute/zone us-west1-a

WORKING_DIR=$(pwd)

CLUSTER_NAME=wordpress-persistent-disk

# WP pwd: nOo^(j&GzEasBh2thT