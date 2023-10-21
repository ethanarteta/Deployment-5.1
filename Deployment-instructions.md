<p align="center">
<img src="https://github.com/kura-labs-org/kuralabs_deployment_1/blob/main/Kuralogo.png">
</p>

## Deployment Instructions:
1. When you create the new instances, first create a new key pair in AWS, save the .pem file on your computer, and attach the new private key to all your instances
2. Recreate a VPC with Terraform **All infrastructure you create below must follow a naming convention including the name of the Deployment e.g. D5.1_VPC, D5.1_Jenkins_EC2, etc.**
The VPC **MUST** have only the components listed below:
    - 1 VPC
    - 2 AZ's
    - 2 Public Subnets
    - 3 EC2s (The application instances should be in their own subnet) 
    - 1 Route Table
    - Security Group Ports: 8080, 8000, 22
3. For the Jenkins instance follow the instructions below:
```
- software-properties-common, sudo add-apt-repository -y ppa:deadsnakes/ppa, python3.7, python3.7-venv}
- Install the following plugin: “Pipeline Keep Running Step”
```
4. On the other 2 instances, install the following:
```
- Install the following: {default-jre, software-properties-common, sudo add-apt-repository -y ppa:deadsnakes/ppa, python3.7, python3.7-venv}
```
5. Make a Jenkins agent on the second instance (how to create a Jenkins agent scribe): [link](https://scribehow.com/shared/Step-by-step_Guide_Creating_an_Agent_in_Jenkins__xeyUT01pSAiWXC3qN42q5w)
6. Create a Jenkins multibranch pipeline and run the Jenkinsfile 
7. Check the application!!
8. Now figure out how to deploy the application on the third instance
9. What should be added to the infrastructure to make the application more available to users?
10. What is the purpose of a Jenkins agent?

Make sure that your documentation speaks to the questions asked above as well as talk to the "why" this specific infrastructure was made for this deployment.  


