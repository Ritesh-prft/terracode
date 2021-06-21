provider "aws" {
  region  = "ap-south-1"
}
#######################state-path###############################

terraform {
  backend "s3" {
    bucket = "jenkins-bucket-tfstate"
    key = "glue-job.tfstate"
    region = "ap-south-1"
    encrypt = true
  }
}


################################################################
# RESOURCES
################################################################ 
resource "random_id" "random" {
  byte_length = 2
}

#######################Glue-Job#################################
resource "aws_glue_job" "aws-glue-src-to-ing-pipeline" {
  name     = "aws-glue-src-to-ing-pipeline-${terraform.workspace}-${random_id.random.id}"
  role_arn = "arn:aws:iam::466515034134:role/ecs-admin"
  command {
    script_location = "s3://jenkins-bucket-tfstate/test.py"
  }
}
########################Glue-Crawler############################
resource "aws_glue_crawler" "db-ingested-data-master-crawler" {
  database_name   = "db-ingested-data-master-development-63899"
  name            = "db-ingested-data-master--crawler-${terraform.workspace}-${random_id.random.id}"
  role            = "ecs-admin"
  s3_target {
    path = "s3://jenkins-bucket-tfstate"
  }
}

resource "aws_glue_job" "aws-glue-src-to-ing-pipeline" {
  name     = "aws-glue-src-to-ing-pipeline-${terraform.workspace}-${random_id.random.id}"
  role_arn = "arn:aws:iam::466515034134:role/ecs-admin"
  command {
    script_location = "s3://jenkins-bucket-tfstate/${aws_glue_job.aws-glue-src-to-ing-pipelin.name}.py"
  }
  depends_on = [
    aws_glue_job.aws-glue-src-to-ing-pipeline,
  ]
}