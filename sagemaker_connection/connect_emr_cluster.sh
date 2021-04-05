# OVERVIEW
# This script connects an Amazon EMR cluster to an Amazon SageMaker notebook instance that uses Sparkmagic.
#
# Note that this script will fail if the Amazon EMR cluster's master node IP address is not reachable.
#   1. Ensure that the EMR master node IP is resolvable from the notebook instance.
#      One way to accomplish this is to have the notebook instance and the Amazon EMR cluster in the same subnet.
#   2. Ensure the EMR master node security group provides inbound access from the notebook instance security group.
#       Type        - Protocol - Port - Source
#       Custom TCP  - TCP      - 8998 - $NOTEBOOK_SECURITY_GROUP
#   3. Ensure the notebook instance has internet connectivity to fetch the SparkMagic example config.
#
# https://aws.amazon.com/blogs/machine-learning/build-amazon-sagemaker-notebooks-backed-by-spark-in-amazon-emr/


file="/home/ec2-user/SageMaker/emr_config.json"
echo $file

EMR_MASTER_IP=$(jq '.ip' $file)
echo $EMR_MASTER_IP

EMR_MASTER_IP=${EMR_MASTER_IP:1:-1}
echo $EMR_MASTER_IP

cd /home/ec2-user/.sparkmagic

echo "Fetching Sparkmagic example config from GitHub..."
wget https://raw.githubusercontent.com/jupyter-incubator/sparkmagic/master/sparkmagic/example_config.json

echo "Replacing EMR master node IP in Sparkmagic config..."
sed -i -- "s/localhost/$EMR_MASTER_IP/g" example_config.json
mv example_config.json config.json

echo "Sending a sample request to Livy.."
curl "$EMR_MASTER_IP:8998/sessions"
                