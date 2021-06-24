#############################################################################
# RESOURCES
#############################################################################  
resource "random_id" "random" {
  byte_length = 2
}


######## Data #################

data "aws_availability_zones" "available" {
  state = "available"
}

##### VPC Routable ############

resource "aws_vpc" "main" {
  cidr_block = "10.190.11.0/28"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name           = "mainvpc-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}

resource "aws_subnet" "private" {
  cidr_block = "10.190.11.0/28"
  vpc_id     = aws_vpc.main.id

  tags = {
    Name           = "privatesubnet-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name           = "iwg-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name           = "default-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.default.id
}

##### VPC Tableau ############

resource "aws_vpc" "tableau" {
  cidr_block = "10.126.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name           = "tableauvpc-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}

resource "aws_subnet" "private1" {
  cidr_block        = "10.126.0.0/24"
  vpc_id            = aws_vpc.tableau.id
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name           = "privatesubnet1-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}

resource "aws_subnet" "private2" {
  cidr_block        = "10.126.1.0/24"
  vpc_id            = aws_vpc.tableau.id
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name           = "privatesubnet2-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}

resource "aws_subnet" "private3" {
  cidr_block        = "10.126.2.0/24"
  vpc_id            = aws_vpc.tableau.id
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name           = "privatesubnet3-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}


resource "aws_route_table" "tableaudefault" {
  vpc_id = aws_vpc.tableau.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_vpc_peering_connection.cigna.id
  }

  tags = {
    Name           = "tableaudefault-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}

resource "aws_default_security_group" "tableaudefault" {
  vpc_id = aws_vpc.tableau.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.tableaudefault.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.tableaudefault.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.tableaudefault.id
}


######### VPC Peering Routable to Tableau ##################

resource "aws_vpc_peering_connection" "cigna" {
  peer_vpc_id = aws_vpc.tableau.id
  vpc_id      = aws_vpc.main.id
  auto_accept = true

  tags = {
    Name           = "peering-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}


######### VPC Endpoints for Routable VPC ###################

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.us-east-2.s3"
  route_table_ids = [aws_route_table.default.id]
  policy          = <<POLICY
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
POLICY

  tags = {
    Name           = "s3-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.default.id

}

resource "aws_vpc_endpoint" "athena" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-2.athena"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_default_security_group.default.id
  ]

  private_dns_enabled = true
  policy              = <<POLICY
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
POLICY

  tags = {
    Name           = "athena-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}

resource "aws_vpc_endpoint_subnet_association" "private_athena" {
  vpc_endpoint_id = aws_vpc_endpoint.athena.id
  subnet_id       = aws_subnet.private.id
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.us-east-2.dynamodb"
  route_table_ids = [aws_route_table.default.id]
  policy          = <<POLICY
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
POLICY

  tags = {
    Name           = "dynamodb-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
  route_table_id  = aws_route_table.default.id

}

resource "aws_vpc_endpoint" "glue" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-2.glue"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_default_security_group.default.id
  ]

  private_dns_enabled = true

  policy = <<POLICY
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
POLICY

  tags = {
    Name           = "glue-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}

resource "aws_vpc_endpoint_subnet_association" "private_glue" {
  vpc_endpoint_id = aws_vpc_endpoint.glue.id
  subnet_id       = aws_subnet.private.id
}

##### S3 Buckets #####

module "s3-bucket1" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.2.0"

  bucket = "aws-athena-query-results-db-${terraform.workspace}-${local.random_number}"
  acl    = "private"

  tags = {
    Name           = "aws-athena-query-results-db-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }
}

module "s3-bucket2" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.2.0"

  bucket = "aws-glue-audit-data-master-${terraform.workspace}-${local.random_number}"
  acl    = "private"

  tags = {
    Name           = "aws-glue-audit-data-master-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application

  }
}

module "s3-bucket3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.2.0"

  bucket = "aws-glue-curated-data-masterr-${terraform.workspace}-${local.random_number}"
  acl    = "private"

  tags = {
    Name           = "aws-glue-curated-data-master-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application

  }
}

module "s3-bucket4" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.2.0"

  bucket = "aws-glue-ingested-data-master-${terraform.workspace}-${local.random_number}"
  acl    = "private"

  tags = {
    Name           = "aws-glue-ingested-data-master-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application

  }
}

module "s3-bucket5" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.2.0"

  bucket = "aws-glue-source-data-master-${terraform.workspace}-${local.random_number}"
  acl    = "private"

  tags = {
    Name           = "aws-glue-source-data-master-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application

  }
}

module "s3-bucket6" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.2.0"

  bucket = "aws-glue-source-scripts-${terraform.workspace}-${local.random_number}"
  acl    = "private"

  tags = {
    Name           = "aws-glue-source-scripts-${terraform.workspace}-${local.random_number}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application

  }
}

##### S3 Uploading scripts ###################################

resource "aws_s3_bucket_object" "object" {
  for_each = fileset("/home/prft-obed/projects/testTerraform/glueJobs", "*")
  bucket   = module.s3-bucket6.s3_bucket_id
  key      = each.value
  source   = "/home/prft-obed/projects/testTerraform/glueJobs/${each.value}"

  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("/home/prft-obed/projects/testTerraform/glueJobs/${each.value}")
}

##### IAM Resources ##########################################

resource "aws_iam_group_policy" "glue_developers_policy" {
  name  = "glue_developers_policy"
  group = aws_iam_group.glue_developers.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource" : [
          "${module.s3-bucket1.s3_bucket_arn}*",
          "${module.s3-bucket2.s3_bucket_arn}*",
          "${module.s3-bucket3.s3_bucket_arn}*",
          "${module.s3-bucket4.s3_bucket_arn}*",
          "${module.s3-bucket5.s3_bucket_arn}*"
        ]
      }
    ]
  })
}

resource "aws_iam_group" "glue_developers" {
  name = "glue_developers"
  path = "/"
}

resource "aws_iam_policy" "AWSGlueServiceRolePolicy" {
  name        = "AWSGlueServiceRolePolicy${terraform.workspace}"
  path        = "/"
  description = "This policy enables AWS Glue right permissions needed to perform its work on ${terraform.workspace} environment"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "glue:*",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:GetBucketAcl",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeRouteTables",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcAttribute",
          "iam:ListRolePolicies",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "cloudwatch:PutMetricData"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:CreateBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::aws-glue-*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::aws-glue-*/*",
          "arn:aws:s3:::*/*aws-glue-*/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:s3:::crawler-public*",
          "arn:aws:s3:::aws-glue-*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : [
          "arn:aws:logs:*:*:/aws-glue/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        "Condition" : {
          "ForAllValues:StringEquals" : {
            "aws:TagKeys" : [
              "aws-glue-service-resource"
            ]
          }
        },
        "Resource" : [
          "arn:aws:ec2:*:*:network-interface/*",
          "arn:aws:ec2:*:*:security-group/*",
          "arn:aws:ec2:*:*:instance/*"
        ]
      }
    ]
  })

  tags = {
    Name           = "AWSGlueServiceRolePolicy${terraform.workspace}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }

}

resource "aws_iam_role" "AWSGlueServiceRole" {
  name        = "AWSGlueServiceRole${terraform.workspace}"
  description = "This role allows AWS Glue perform actions on  ${terraform.workspace} environment"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "glue.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name           = "AWSGlueServiceRole${terraform.workspace}"
    Project        = var.Project
    Owner          = var.Owner
    BU             = var.Bu
    EBSProjectCode = var.EBSProjectCode
    Environment    = terraform.workspace
    Expiration     = var.Expiration
    Application    = var.Application
  }

}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRolePolicy-attach" {
  role       = aws_iam_role.AWSGlueServiceRole.name
  policy_arn = aws_iam_policy.AWSGlueServiceRolePolicy.arn
}

###### Glue #################################################################

###### Glue Catalog ##########################################################

resource "aws_glue_catalog_database" "catalog_database1" {
  name = "db-audit-data-master-${terraform.workspace}-${local.random_number}"
}

resource "aws_glue_catalog_database" "catalog_database2" {
  name = "db-curated-data-master-${terraform.workspace}-${local.random_number}"
}

resource "aws_glue_catalog_database" "catalog_database3" {
  name = "db-ingested-data-master-${terraform.workspace}-${local.random_number}"
}

resource "aws_glue_catalog_database" "catalog_database4" {
  name = "db-ingested-data-master_task1-${terraform.workspace}-${local.random_number}"
}

resource "aws_glue_catalog_database" "catalog_database5" {
  name = "db-source-data-master-${terraform.workspace}-${local.random_number}"
}

resource "aws_glue_catalog_database" "catalog_database6" {
  name = "db_esi-${terraform.workspace}-${local.random_number}"
}

###### Glue Connections ######################################################

resource "aws_glue_connection" "toS3" {
  connection_type = "NETWORK"
  connection_properties = {
    description = "This is a connection for the test S3"
  }

  name = "test"

  physical_connection_requirements {
    availability_zone = aws_subnet.private.availability_zone
    subnet_id         = aws_subnet.private.id
    security_group_id_list = [
      aws_default_security_group.default.id
    ]
  }

}

###### Glue Jobs #############################################################

resource "aws_glue_job" "aws-glue-src-to-ing-pipeline" {
  name     = "aws-glue-src-to-ing-pipeline-${terraform.workspace}-${local.random_number}"
  role_arn = aws_iam_role.AWSGlueServiceRole.arn

  command {
    script_location = "s3://${module.s3-bucket6.s3_bucket_id}/test_test1_python.py"
  }
}

resource "aws_glue_job" "aws-glue-ing-to-cur-pipeline" {
  name     = "aws-glue-ing-to-cur-pipeline-${terraform.workspace}-${local.random_number}"
  role_arn = aws_iam_role.AWSGlueServiceRole.arn

  command {
    script_location = "s3://${module.s3-bucket6.s3_bucket_id}/test_test1_python.py"
  }
}

resource "aws_glue_job" "aws-glue-ing-to-cur-invoicedata-pipeline" {
  name     = "aws-glue-ing-to-cur-invoicedata-pipeline-${terraform.workspace}-${local.random_number}"
  role_arn = aws_iam_role.AWSGlueServiceRole.arn

  command {
    script_location = "s3://${module.s3-bucket6.s3_bucket_id}/test_test1_python.py"
  }
}

resource "aws_glue_job" "aws-glue-master-ingestion-pipeline" {
  name     = "aws-glue-master-ingestion-pipeline-${terraform.workspace}-${local.random_number}"
  role_arn = aws_iam_role.AWSGlueServiceRole.arn

  command {
    script_location = "s3://${module.s3-bucket6.s3_bucket_id}/test_test1_python.py"
  }
}

resource "aws_glue_job" "aws-glue-master-curation-pipeline" {
  name     = "aws-glue-master-curation-pipeline-${terraform.workspace}-${local.random_number}"
  role_arn = aws_iam_role.AWSGlueServiceRole.arn

  command {
    script_location = "s3://${module.s3-bucket6.s3_bucket_id}/test_test1_python.py"
  }
}


resource "aws_glue_job" "aws-glue-connect-to-snowflake" {
  name     = "aws-glue-connect-to-snowflake-${terraform.workspace}-${local.random_number}"
  role_arn = aws_iam_role.AWSGlueServiceRole.arn

  command {
    script_location = "s3://${module.s3-bucket6.s3_bucket_id}/test_test1_python.py"
  }
}

###### Glue Crawlers ########################################################

resource "aws_glue_crawler" "db-ingested-data-master-crawler" {
  database_name   = aws_glue_catalog_database.catalog_database3.name
  name            = "db-ingested-data-master--crawler-${terraform.workspace}-${local.random_number}"
  role            = aws_iam_role.AWSGlueServiceRole.arn

  s3_target {
    path = "s3://${module.s3-bucket4.s3_bucket_id}"
    connection_name = aws_glue_connection.toS3.name
  }
}

#############################################################################
# OUTPUTS
#############################################################################

output "s3_arn" {
  value = "${module.s3-bucket1.s3_bucket_arn}"
}