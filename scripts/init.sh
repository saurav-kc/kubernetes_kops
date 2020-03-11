export nodecount=1
export AWS_DEFAULT_REGION=us-east-1

export ZONES=$(aws ec2 describe-availability-zones \
    --region $AWS_DEFAULT_REGION | jq -r \
    '.AvailabilityZones[].ZoneName' | head -$nodecount | tr '\n' ',' | tr -d ' ')

ZONES=${ZONES%?}

# Must change: Your domain name that is hosted in AWS Route 53
export DOMAIN_NAME="hostreserve.tech"

# Friendly name to use as an alias for your cluster
export CLUSTER_ALIAS="k8sintelycore"

# Leave as-is: Full DNS name of you cluster
export CLUSTER_FULL_NAME="${CLUSTER_ALIAS}.${DOMAIN_NAME}"

# Bucket name for state store of kops and Terraform.
export BUCKET_NAME=k8s-intelycore

# Create bucket here if needed

export KOPS_STATE_STORE=s3://$BUCKET_NAME

# Create cluster config

kops create cluster \
--name=${CLUSTER_FULL_NAME} \
--zones=${ZONES} \
--master-size="t2.medium" \
--node-size="t2.medium" \
--node-count="1" \
--dns-zone=${DOMAIN_NAME} \
--ssh-public-key="k8sintelycore.pub"

# Review it before the cluster gets created in AWS
# kops edit cluster --name $CLUSTER_FULL_NAME

# Create AWS resources
kops update cluster --name "$CLUSTER_FULL_NAME" --yes

