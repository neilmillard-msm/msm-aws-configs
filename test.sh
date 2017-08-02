#!/bin/sh -e

echo "-- Create a sample file to put into the bucket"
echo 'Terraformed!' > mcloud.txt

echo "-- Get all needed modules"
terraform get
echo "-- Refresh infrastructure state"
for BUCKET in msm-gb-all-bucket2 msm-gb-any-bucket1 msm-gb-any-buckets-log
do
    if aws s3api head-bucket --bucket "${BUCKET}" &>/dev/null
    then
        terraform import aws_s3_bucket.bucket "${BUCKET}"
        break
    fi
done
terraform refresh
echo "-- Create a terraforming plan"
terraform plan -out mcloud.tfplan
echo "-- Create / Update the infrastructure"
terraform apply mcloud.tfplan

echo "-- Test that the buckets are there"
aws s3 cp mcloud.txt s3://msm-gb-any-bucket1/objects/mcloud.txt
aws s3 ls s3://msm-gb-any-bucket1/objects/mcloud.txt

# Destroy the infrastructure: if versioning is enabled, there is a missing
# feature in terraform that prevents it to properly handle the deletion.
#
# terraform destroy

for BUCKET in msm-gb-all-bucket2 msm-gb-any-bucket1 msm-gb-any-buckets-log
do

    VERSIONS=$(aws s3api list-object-versions --bucket "${BUCKET}" | jq '.Versions')
    MARKERS=$(aws s3api list-object-versions --bucket "${BUCKET}" | jq '.DeleteMarkers')

    echo "-- Removing all objects from ${BUCKET}"
    for VERSION in $(echo "${VERSIONS}" | jq --raw-output '.[] | @base64'); do
        VERSION=$(echo "${VERSION}" | base64 --decode)

        KEY=$(echo "${VERSION}" | jq --raw-output .Key)
        VERSION_ID=$(echo "${VERSION}" | jq --raw-output .VersionId)
        CMD="aws s3api delete-object --bucket ${BUCKET} --key ${KEY} --version-id ${VERSION_ID}"
        echo $CMD
        $CMD
    done

    test "${MARKERS}" = "null" && continue

    echo "-- Removing all delete markers from ${BUCKET}"
    for MARKER in $(echo "${MARKERS}" | jq --raw-output '.[] | @base64'); do
        MARKER=$(echo "${MARKER}" | base64 --decode)

        KEY=$(echo "${MARKER}" | jq --raw-output .Key)
        VERSION_ID=$(echo "${MARKER}" | jq --raw-output .VersionId)
        CMD="aws s3api delete-object --bucket ${BUCKET} --key ${KEY} --version-id ${VERSION_ID}"
        echo $CMD
        $CMD
    done

    echo "-- Removing ${BUCKET}"
    aws s3api delete-bucket --bucket ${BUCKET}
done

echo "-- Listing available buckets"
aws s3api list-buckets | jq --raw-output '.Buckets[].Name' |\
    grep -e msm-gb-all-bucket2 -e msm-gb-any-bucket1 -e msm-gb-any-buckets-log
