#!/bin/bash
# "Deploys" the current version of our docs on S3
BUILD_FOLDER=site
S3_BUCKET=s3://docs.riseml.com/

cd ..
# Clean local build
rm -r $BUILD_FOLDER
# Create local repository folder (if not present)
mkdir -p $BUILD_FOLDER

# Create package
mkdocs build -f docs/mkdocs.yml -d $BUILD_FOLDER
# Remove artifacts that don' belong deployed
rm $BUILD_FOLDER/mkdocs.yml
rm $BUILD_FOLDER/requirements.txt

# Sync local build folder > remote s3 bucket, delete remote files not present locally
aws s3 sync --delete $BUILD_FOLDER $S3_BUCKET --dryrun

# Invalidate CloudFront CDN
aws configure set preview.cloudfront true
aws cloudfront create-invalidation --distribution-id E18Z09OA3VI8UF --paths "/*"
cd docs
