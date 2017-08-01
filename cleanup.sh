for BUCKET in msm-gb-all-bucket2 msm-gb-any-bucket1 msm-gb-any-buckets-log
do

    VERSIONS=$(aws s3api list-object-versions --bucket "${BUCKET}" | jq '.Versions')
    MARKERS=$(aws s3api list-object-versions --bucket "${BUCKET}" | jq '.DeleteMarkers')

    echo "Removing all objects from ${BUCKET}"
    for VERSION in $(echo "${VERSIONS}" | jq -r '.[] | @base64'); do
        VERSION=$(echo "${VERSION}" | base64 --decode)

        KEY=$(echo "${VERSION}" | jq -r .Key)
        VERSION_ID=$(echo "${VERSION}" | jq -r .VersionId)
        CMD="aws s3api delete-object --bucket ${BUCKET} --key ${KEY} --version-id ${VERSION_ID}"
        echo $CMD
        $CMD
    done

    echo "Removing all delete markers from ${BUCKET}"
    for marker in $(echo "${MARKERS}" | jq -r '.[] | @base64'); do
        marker=$(echo ${marker} | base64 --decode)

        KEY=`echo $marker | jq -r .Key`
        VERSION_ID=`echo $marker | jq -r .VersionId `
        CMD="aws s3api delete-object --bucket ${BUCKET} --key ${KEY} --version-id ${VERSION_ID}"
        echo $CMD
        $CMD
    done

    echo "Removing ${BUCKET}"
    aws s3api delete-bucket --bucket ${BUCKET}
done
