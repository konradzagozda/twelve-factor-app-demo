resource "random_pet" "bucket_suffix" {
  length    = 2
  separator = "-"
}

resource "aws_s3_bucket" "releases" {
  bucket              = "releases-${random_pet.bucket_suffix.id}"
  object_lock_enabled = true
  force_destroy       = true
}

resource "aws_s3_bucket_versioning" "releases" {
  bucket = aws_s3_bucket.releases.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "releases" {
  bucket = aws_s3_bucket.releases.id

  rule {
    default_retention {
      mode  = "GOVERNANCE" // change to COMPLIANCE to ensure it's NEVER deleted
      years = 10
    }
  }
}

resource "aws_s3_bucket" "configurations" {
  bucket              = "configurations-${random_pet.bucket_suffix.id}"
  object_lock_enabled = true
  force_destroy       = true
}



resource "aws_s3_bucket_versioning" "configurations" {
  bucket = aws_s3_bucket.configurations.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "configurations" {
  bucket = aws_s3_bucket.configurations.id

  rule {
    default_retention {
      mode  = "GOVERNANCE" // change to COMPLIANCE to ensure it's NEVER deleted
      years = 10
    }
  }
}