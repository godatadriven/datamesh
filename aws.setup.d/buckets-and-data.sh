#!/bin/bash
set -x
awslocal s3 mb s3://$DEMO_BUCKET
awslocal s3 cp /initdata/worldcities.csv s3://$DEMO_BUCKET/rawdata/world/cities/sample.csv
awslocal s3 cp /initdata/sales_data_sample.csv s3://$DEMO_BUCKET/rawdata/sales/sample.csv
awslocal s3 cp /initdata/cities s3://$DEMO_BUCKET/silver/world/cities --recursive
awslocal s3 cp /initdata/sales s3://$DEMO_BUCKET/silver/sales --recursive
set +x
