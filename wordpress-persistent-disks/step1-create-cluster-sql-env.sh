source ./step0-env.sh

# Create k8s cluster and PV/PVC
gcloud container clusters create $CLUSTER_NAME \
    --num-nodes=3 --enable-autoupgrade --no-enable-basic-auth \
    --no-issue-client-certificate --enable-ip-alias --metadata \
    disable-legacy-endpoints=true

# 2. Creating a PV and a PVC backed by Persistent Disk
kubectl apply -f $WORKING_DIR/wordpress-volumeclaim.yaml

## Check the pvc status
kubectl get persistentvolumeclaim

## Creating a Cloud SQL for MySQL instance
gcloud sql instances create $INSTANCE_NAME

## Export the env variable for substitution of the deploy file 
## "wordpress_cloudsql.yaml"(in Step3-deploy-wordpress)
export INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe $INSTANCE_NAME \
    --format='value(connectionName)')

## Create a database for Wordpress
gcloud sql databases create wordpress --instance $INSTANCE_NAME    

## Create DB user
CLOUD_SQL_PASSWORD=$(openssl rand -base64 18)
echo "export CLOUD_SQL_PASSWORD=$CLOUD_SQL_PASSWORD" >> ~/.profile  
gcloud sql users create wordpress \
    --host=% \
    --instance $INSTANCE_NAME \
    --password $CLOUD_SQL_PASSWORD



