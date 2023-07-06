{
    "Comment": "A description of my state machine",
    "StartAt": "ECS RunTask",
    "States": {
      "ECS RunTask": {
        "Type": "Task",
        "Resource": "arn:aws:states:::ecs:runTask",
        "Parameters": {
          "Cluster": "experimentCluster",
          "LaunchType": "FARGATE",
          "TaskDefinition": "${SplashTaskDef}",
          "NetworkConfiguration": {
            "AwsvpcConfiguration": {
              "AssignPublicIp": "ENABLED",
              "Subnets": "${TaskSubnets}",
              "SecurityGroups": [
                "${TaskSecurityGroup}"
              ]
            }
          }
        },
        "Next": "Wait",
        "ResultSelector": {
          "TaskArn.$": "$.Tasks[*].TaskArn"
        },
        "ResultPath": "$.TaskArn"
      },
      "Wait": {
        "Type": "Wait",
        "Seconds": 75,
        "Next": "DescribeTasks"
      },
      "DescribeTasks": {
        "Type": "Task",
        "Next": "Choice",
        "Parameters": {
          "Cluster": "experimentCluster",
          "Tasks.$": "$.TaskArn.TaskArn"
        },
        "Resource": "arn:aws:states:::aws-sdk:ecs:describeTasks",
        "ResultPath": "$.Tasks[0]"
      },
      "Choice": {
        "Type": "Choice",
        "Choices": [
          {
            "Not": {
              "Variable": "$.Tasks[0].Tasks[0].Containers[0].NetworkInterfaces[0].PrivateIpv4Address",
              "IsPresent": true
            },
            "Next": "Fail"
          }
        ],
        "Default": "Lambda Invoke"
      },
      "Fail": {
        "Type": "Fail"
      },
      "Lambda Invoke": {
        "Type": "Task",
        "Resource": "arn:aws:states:::lambda:invoke.waitForTaskToken",
        "OutputPath": "$.Payload",
        "Parameters": {
          "FunctionName": "${LambdaArn}",
          "Payload": {
            "url.$": "$.Tasks[0].Tasks[0].Containers[0].NetworkInterfaces[0].PrivateIpv4Address",
            "target.$": "$.targeturl"
          }
        },
        "Retry": [
          {
            "ErrorEquals": [
              "Lambda.ServiceException",
              "Lambda.AWSLambdaException",
              "Lambda.SdkClientException",
              "Lambda.TooManyRequestsException"
            ],
            "IntervalSeconds": 2,
            "MaxAttempts": 6,
            "BackoffRate": 2
          }
        ],
        "Next": "StopTask",
        "Catch": [
          {
            "ErrorEquals": [
              "States.ALL"
            ],
            "Comment": "No NetworkID",
            "Next": "StopTask"
          }
        ]
      },
      "StopTask": {
        "Type": "Task",
        "Parameters": {
          "Cluster": "experimentCluster",
          "Task.$": "$.Tasks.Attachments.Details.Name"
        },
        "Resource": "arn:aws:states:::aws-sdk:ecs:stopTask",
        "End": true
      }
    }
  }