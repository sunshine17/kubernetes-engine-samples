source ./step0-env.sh

# 1. Configure a service account and create secrets
echo "1. Configure a service account and create secrets"
SA_NAME=cloudsql-proxy
gcloud iam service-accounts create $SA_NAME --display-name $SA_NAME
SA_EMAIL=$(gcloud iam service-accounts list \
    --filter=displayName:$SA_NAME \
    --format='value(email)')
echo "Step #1 DONE."

# 2. Bind cloudsql.client role to IAM with the project
echo "2. Bind cloudsql.client role to IAM with the project \n"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --role roles/cloudsql.client \
    --member serviceAccount:$SA_EMAIL
echo "Step #2 DONE."

# 3. Create key for the service account(This command downloads a copy of the key.json file)
echo "3. Create key for the service account(This command downloads a copy of the key.json file) \n"
SA_KEY_FILE=~/.sa-key.json
gcloud iam service-accounts keys create $SA_KEY_FILE \
    --iam-account $SA_EMAIL
echo "Step #3 DONE."

# 4. Use Kubernetes secret to store the MySQL and service account credentials
echo "4. Use Kubernetes secret to store the MySQL and service account credentials \n"

## 4.1 for MySQL credentials:
kubectl create secret generic cloudsql-db-credentials \
    --from-literal username=wordpress \
    --from-literal password=$CLOUD_SQL_PASSWORD

## 4.2 for service account credentials:
kubectl create secret generic cloudsql-instance-credentials \
    --from-file $SA_KEY_FILE

echo  "Step #4 DONE.\n"

# 5. Deploy
echo  "5. Deploy"

## 5.1Prepare the file by replacing the INSTANCE_CONNECTION_NAME environment variable:
cat $WORKING_DIR/wordpress_cloudsql.yaml.template | envsubst > \
    $WORKING_DIR/wordpress_cloudsql.yaml
kubectl create -f $WORKING_DIR/wordpress_cloudsql.yaml
kubectl get pod -l app=wordpress --watch

## 5.2 Expose the Wordpress service
kubectl create -f $WORKING_DIR/wordpress-service.yaml
kubectl get svc -l app=wordpress --watch

echo "Step #5 DONE."