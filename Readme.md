# Infrastructure for HeriTools services

- [x] 1: Source bucked
- [x] 2: Destination bucket
- [ ] 3: CloudFront
- [x] Domain routing
- [x] Domain Certificates
- [ ] SQS Queue (store queued jobs)
- [ ] IAM roles
- [ ] ECS cluster and task definition
- [ ] Scaling ECS based on queue size
- [ ] Cloud watch logs for the container


## 1: Source bucket
Stored the RAW uploads that will later be processed

## 2: Destination Bucket
Stores the generated tiles / assets, sits behind cloudfront CDN

## Cloud Front CDN
CDN to serve the Destination bucket

## 3: Domain routing
Give cloudfront CDN a custom domain name

## Domain Certificate
Setup SSL certificate for custom domain

## SQS Queue
Queue for storing jobs