resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "main" {
  name = "${var.task_name}-log-group"

  tags = var.common_tags
}

resource "aws_iam_role" "task" {
  name = "${var.task_name}-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "ecs-tasks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

  tags = var.common_tags
}

resource "aws_iam_role_policy" "task" {
  name   = "${aws_iam_role.task.name}-policy"
  role   = aws_iam_role.task.id
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
            "secretsmanager:GetSecretValue"
      ],
			"Resource": ["${var.secrets_manager_arn}"]
		}
	]
}
EOF
}

resource "aws_iam_role" "task_executor" {
  name = "${var.task_name}-execution-role"

  assume_role_policy = <<EOF

{
    "Version": "2012-10-17",
    "Statement": [

        {
            "Sid": "",
            "Effect": "Allow",

            "Principal": {
                "Service": [
                    "ecs-tasks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}

EOF

  tags = var.common_tags
}

resource "aws_iam_role_policy" "task_executor" {
  name   = "${aws_iam_role.task_executor.name}-execution-policy"
  role   = aws_iam_role.task_executor.id
  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage"
         ],
         "Resource":[
            "*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "logs:CreateLogStream",
            "logs:PutLogEvents"
         ],
         "Resource":[
            "*"
         ]
      }
     
   ]
}
EOF
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.task_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu_units
  memory                   = var.memory_in_mb

  task_role_arn      = aws_iam_role.task.arn
  execution_role_arn = aws_iam_role.task_executor.arn

  container_definitions = jsonencode([
    {
      "name" : var.container_name,
      "image" : var.image_url,
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : var.container_port,
          "hostPort" : var.host_port,
          "protocol" : "tcp"
        }
      ]
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : aws_cloudwatch_log_group.main.name,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : var.task_name
        }
      }
    }
  ])
}

resource "aws_security_group" "main" {
  name   = "${var.service_name}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags,
    {
      Name = "${var.service_name}_sg"
    }
  )

}


resource "aws_ecs_service" "main" {
  name                = var.service_name
  cluster             = aws_ecs_cluster.main.id
  task_definition     = aws_ecs_task_definition.main.arn
  scheduling_strategy = "REPLICA"
  launch_type         = "FARGATE"
  desired_count       = 1

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.main.id]
  }

  load_balancer {
    target_group_arn = var.lb_tg_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}
