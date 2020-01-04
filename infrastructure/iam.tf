resource "aws_iam_role" "kinesis-analytics-flink-s3" {
  name = "kinesis-analytics-flink-s3"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "kinesisanalytics.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "kinesis-access" {
  name        = "kinesis-test-stream-full"
  description = "Full access to the Kinesis test-stream"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kinesis:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kinesis_stream.stream.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kinesis-analytics-flink-s3_kinesis-access" {
  role       = aws_iam_role.kinesis-analytics-flink-s3.name
  policy_arn = aws_iam_policy.kinesis-access.arn
}

resource "aws_iam_policy" "s3-access" {
  name        = "s3-${aws_s3_bucket.bucket.bucket_prefix}-full"
  description = "Full access to the Kinesis test-stream"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
         "${aws_s3_bucket.bucket.arn}",
         "${aws_s3_bucket.bucket.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kinesis-analytics-flink-s3_s3-access" {
  role       = aws_iam_role.kinesis-analytics-flink-s3.name
  policy_arn = aws_iam_policy.s3-access.arn
}

resource "aws_iam_policy" "cloudwatch-kinesis-analytics-access" {
  name        = "cloudwatch-kinesis-analytics-write"
  description = "Write access to the Cloudtwach kinesis analytics flink log stream"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "DescribeLogGroups",
        "Effect": "Allow",
        "Action": [
            "logs:DescribeLogGroups"
        ],
        "Resource": [
            "*"
        ]
    },
    {
        "Sid": "DescribeLogStreams",
        "Effect": "Allow",
        "Action": [
            "logs:DescribeLogStreams"
        ],
        "Resource": [
            "*"
        ]
    },
    {
        "Sid": "PutLogEvents",
        "Effect": "Allow",
        "Action": [
            "logs:PutLogEvents"
        ],
        "Resource": [
           "${aws_cloudwatch_log_stream.kinesis-flink-s3.arn}"
        ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kinesis-analytics-flink-s3_cloudwatch-kinesis-analytics-write" {
  role       = aws_iam_role.kinesis-analytics-flink-s3.name
  policy_arn = aws_iam_policy.cloudwatch-kinesis-analytics-access.arn
}
