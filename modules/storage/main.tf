resource "aws_s3_bucket" "sri-quickbasket-img-production" {
  bucket = "sri-quickbasket-img-${var.environment}"
  
}

resource "aws_s3_bucket_versioning" "sri-quickbasket-img-versioning" {
  bucket = aws_s3_bucket.sri-quickbasket-img-production.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "quickbasket_img_s3_policy" {
  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.sri-quickbasket-img-production.arn}/*"   ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.quickbasket_img_fetch_cloudfront_arn]
    }




  }

}

resource "aws_s3_bucket_policy" "quickbasket-img-fetch-cldfrnt-oac-policy" {
  bucket = aws_s3_bucket.sri-quickbasket-img-production.id
  policy = data.aws_iam_policy_document.quickbasket_img_s3_policy.json
}



resource "aws_s3_bucket_public_access_block" "sri-quickbasket-img-Public_access_block" {
  bucket = aws_s3_bucket.sri-quickbasket-img-production.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true 
}


resource "aws_s3_bucket" "sri-quickbasket-loki-logs-production" {
  bucket = "sri-quickbasket-loki-logs-${var.environment}"
  
}

resource "aws_s3_bucket_versioning" "sri-quickbasket-loki-logs-versioning" {
  bucket = aws_s3_bucket.sri-quickbasket-loki-logs-production.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "sri-quickbasket-loki-logs-Public_access_block" {
  bucket = aws_s3_bucket.sri-quickbasket-loki-logs-production.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true 
}