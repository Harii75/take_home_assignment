data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "DenyNonTLS"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.backup.arn,
      "${aws_s3_bucket.backup.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "AllowCrossAccountBackupUploader"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.backup_uploader_role_arn]
    }

    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]

    resources = ["${aws_s3_bucket.backup.arn}/*"]
  }

  statement {
    sid    = "DenyUploaderDestructiveActions"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = [var.backup_uploader_role_arn]
    }

    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:PutLifecycleConfiguration",
      "s3:PutBucketPolicy",
      "s3:PutBucketVersioning",
    ]

    resources = [
      aws_s3_bucket.backup.arn,
      "${aws_s3_bucket.backup.arn}/*",
    ]
  }
}
