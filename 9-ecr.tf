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
