

output source_bucket_arn {
    value = "${aws_s3_bucket.app_s3_bucket.arn}"
}