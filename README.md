# Terraform Deployment Documentation

## Purpose
This documentation provides an overview of deploying a Banking Application using Terraform. The goal is to create a Terraform file with specific components and set up Jenkins for continuous integration, enabling the deployment of an application across multiple EC2 instances.

## Issues
Had an issue with Jenkins not deploying to both ec2 instances. To resolve I restarted the ec2 instance that would not deploy and no more issues were encountered.
## Steps

### Step 1: Terraform Creation
1. Terraform was used to create an instance along with its Infrastructure with the specified components.
This deployment needs:
- 1 Virtual Private Cloud
- 2 Availability Zones
- 2 Public Subnets
- 3 EC2 Instances
- 1 Route Table
- Security Group Ports: 8080, 8000, 22
  During this stage, I implemented a Deploy.sh script in the User Data prompt. That script installed Jenkins and its dependencies. Additionally made a second script to download Python and all related dependencies.
   
### Step 2: EC2 Instance Setup
**For the first EC2 instance (Instance 1):**
1. Once Jenkins is installed.
2. Create a Jenkins user password and log into the Jenkins user.
3. Installed "Pipeline keep running step" plugin.

**For the second and third EC2 instance (Instance 2+3):**
1. Install the following software: `sudo apt install -y software-properties-common`, `sudo add-apt-repository -y ppa:deadsnakes/ppa`, `sudo apt install -y python3.7`, `sudo apt install -y python3.7-venv`. I used a Script to automate this step

### Step 3: Made Jenkins agents
1. Following these Steps:
    - Select "Build Executor Status"
    - Click "New Node"
    - Choose a node name that will correspond with the Jenkins agent defined in our Jenkins file
    - Select permenant Agent
    - Create the node
    - Use the same name for the name field
    - Enter "/home/ubuntu/agent1" as the "Remote root directory"
    - Use the same name for the labels field
    - Click the dropdown menu and select "only build jobs with label expressions matching this node"
    - Click the dropdown menu and select "launch agent via SSH"
    - Enter the public IP address of the instance you want to install the agent on, in the "Host" field
    - Click "Add" to add Jenkins credentials
    - Click the dropdown menu and select "select SSH username with private key"
    - Use the same name for the ID field 
    - Use "ubuntu" for the username
    - Enter directly & add the private key by pasting it into the box
    - Click "Add" and select the Ubuntu credentials
    - Click the dropdown menu and select "non verifying verification strategy"
    - Click save & check in Jenkins UI for a successful installation by clicking "Log"

### Step 4: Jenkinsfile Configuration
In Jenkinsfile I modified the agent line to use a second label named "awsDeploy2".
```bash
post{
always {
junit 'test-reports/results.xml'
}
}
}
stage ('Clean') {
agent {label 'awsDeploy || awsDeploy2'}
steps {
sh '''#!/bin/bash
if [[ $(ps aux | grep -i "gunicorn" | tr -s " " | head -n 1 | cut -d " " -f 2) != 0 ]]
then
ps aux | grep -i "gunicorn" | tr -s " " | head -n 1 | cut -d " " -f 2 > pid.txt
kill $(cat pid.txt)
exit 0
fi
'''
}
}
```
```bash
stage ('Deploy') {
agent {label 'awsDeploy || awsDeploy2'}
steps {
keepRunning {
sh '''#!/bin/bash
python3.7 -m venv test
source test/bin/activate
pip install pip --upgrade
pip install -r requirements.txt
pip install gunicorn
python database.py
sleep 1
python load_data.py
sleep 1 
python -m gunicorn app:app -b 0.0.0.0 -D && echo "Done"
'''
}
}
}
```
### Step 5: Jenkins Multibranch Pipeline
1. Create a Jenkins multibranch pipeline.
2. Run the Jenkinsfilev.

### Step 6: Application Testing
1. Check the application on Instance 2.
2. Observed it running on port 8000

### Step 7: Application Testing (cont.)
1. Check the application on Instance 3.
2. Observed it running on port 8000

## FAQ

### What should be added to the infrastructure to make the application more available to users?
- To make this application more available we should consider using a load balancer to distribute traffic and ensure high availability. 
- Setting up auto-scaling groups to adjust the number of ec2 instances that will handle more requests during peak times and scaling down during low traffic periods
- We could deploy to more availability zones which would increase fault tolerance if other AZ experience issues
- A CDN like AWS CloudFront could deliver content from edge locations reducing latency and making the application more available to users.
### What is the purpose of a Jenkins Agent
- Jenkins agents allow us to execute multiple builds and deployments on different EC2 instances simultaneously. This reduces the time required to complete tasks and improves efficiency
- Jenkins agents can be configured with specific environments, tools, and dependencies. This isolation ensures that builds and deployments are consistent and independent of each other, reducing potential conflicts.
- Agents distribute the workload, making it possible to scale your Jenkins infrastructure horizontally. As your project grows, you can add more agents to accommodate increased demand.
- Jenkins agents can be distributed across multiple machines, helping balance the load and preventing a single Jenkins master from becoming a bottleneck.

  
### System Diagram
![image](Deployment5.1/Deployment5.1.png)

### Optimization
To make this deployment more efficient, I would implement the following:

1. **Use Terraform Modules:** Break down the Terraform configuration into reusable modules for VPC components, security groups, and EC2 instances to improve code maintainability.

2. **Implement Autoscaling:** Set up auto-scaling groups for EC2 instances to automatically adjust the number of instances based on traffic demands.

3. **Containerization:** Consider containerizing the banking application using Docker and deploying it on an orchestration platform like Kubernetes for more efficient management and scalability.

![image](Deployment5.1/Deployment5.1server1.png)
![image](Deployment5.1/Deployment5.1server2.png)
![image](Deployment5.1/Deployment5.1Jenkins.png)
