#!/bin/bash
# "Deploys" the current version of our docs on S3
BUILD_FOLDER=_book
S3_BUCKET=s3://docs.riseml.com/

# Clean local build
rm -r $BUILD_FOLDER
# Create local repository folder (if not present)
mkdir -p $BUILD_FOLDER

# Create package
gitbook build

# Sync local build folder > remote s3 bucket, delete remote files not present locally
aws s3 sync --delete $BUILD_FOLDER $S3_BUCKET

# Invalidate CloudFront CDN
aws configure set preview.cloudfront true
aws cloudfront create-invalidation --distribution-id E18Z09OA3VI8UF --paths "/*"

