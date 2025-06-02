#!/bin/bash
# This script is used to bootstrap EC2 instances in the Auto Scaling Group

# Update system packages
yum update -y

# Install necessary packages
yum install -y amazon-cloudwatch-agent httpd git

# Start and enable Apache web server
systemctl start httpd
systemctl enable httpd

# Create a simple index.html
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>AWS Gold Image Demo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            color: #333;
            line-height: 1.6;
        }
        .container {
            width: 80%;
            margin: 0 auto;
            overflow: hidden;
            padding: 20px;
        }
        header {
            background: #232f3e;
            color: #fff;
            padding: 20px 0;
            text-align: center;
        }
        .content {
            background: #fff;
            padding: 20px;
            margin-top: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        footer {
            background: #232f3e;
            color: #fff;
            text-align: center;
            padding: 10px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <h1>AWS Gold Image Demo</h1>
        </div>
    </header>
    <div class="container">
        <div class="content">
            <h2>Welcome to the AWS Gold Image Demo</h2>
            <p>This instance was deployed using Infrastructure as Code (IaC) with Terraform.</p>
            <p>Instance ID: <span id="instance-id">Loading...</span></p>
            <p>Availability Zone: <span id="availability-zone">Loading...</span></p>
            <p>Environment: ${ENVIRONMENT}</p>
        </div>
    </div>
    <footer>
        <div class="container">
            <p>&copy; 2023 AWS Gold Image Demo</p>
        </div>
    </footer>
    <script>
        // Fetch instance metadata
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => {
                document.getElementById('instance-id').textContent = data;
            });
        
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(response => response.text())
            .then(data => {
                document.getElementById('availability-zone').textContent = data;
            });
    </script>
</body>
</html>
EOF

# Replace environment placeholder with actual environment
sed -i "s/\${ENVIRONMENT}/$(curl -s http://169.254.169.254/latest/meta-data/tags/instance/Environment)/" /var/www/html/index.html

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "metrics_collected": {
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "resources": [
          "/"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      }
    },
    "append_dimensions": {
      "InstanceId": "${aws:InstanceId}"
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "/aws/ec2/httpd/access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "/aws/ec2/httpd/error",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/system/messages",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch agent
systemctl start amazon-cloudwatch-agent
systemctl enable amazon-cloudwatch-agent

# Tag the instance with additional metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

# Signal completion of user data script
/opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource AutoScalingGroup --region $REGION