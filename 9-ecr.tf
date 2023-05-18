resource "aws_ecr_repository" "taxi_trip_client" {
  name                 = "taxi-trip-client"
  image_tag_mutability = "MUTABLE"
  force_delete        = true
}

resource "aws_ecr_repository" "taxi_trip_api" {
  name                 = "taxi-trip-api"
  image_tag_mutability = "MUTABLE"
  force_delete        = true
}

resource "aws_ecr_repository" "taxi_trip_facade" {
  name                 = "taxi-trip-facade"
  image_tag_mutability = "MUTABLE"
  force_delete        = true
}

resource "aws_ecr_repository" "taxi_trip_totals" {
  name                 = "taxi-trip-totals"
  image_tag_mutability = "MUTABLE"
  force_delete        = true
}
