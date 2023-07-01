# TestStack

This repository contains a CloudFormation stack for deploying resources using CodePipeline and CodeBuild. It has a connection to codepipeline, so every change in the code initializes the execution of the pipeline in CodePipeline, which initializes or updates the stacks and deploys the resources.

## Requirements and Dependencies

Before deploying the stack, make sure you have the following requirements and dependencies configured:

- Access to an AWS account with a role that has the necessary permissions to create and manage resources using AWS CloudFormation and execute the buildspec.yml file in CodeBuild.

- AWS CLI configured with appropriate credentials.

## Creating Parameters in Parameter Store

Before deploying the stack, you need to create three parameters in AWS Systems Manager Parameter Store to store the information of the secrets for the database and the name of the keyring for the EC2 instance:

1. `SecretId`: This parameter should contain the identifier of the secret for the database.
2. `SecretArn`: This parameter should contain the Amazon Resource Name (ARN) of the secret for the database.
3. `EC2KeyPair`: This parameter should contain the name of the keyring for the EC2 instance.

## Creating a Pipeline in CodePipeline

To create a pipeline in CodePipeline and connect it to your GitHub repository for deploying the CloudFormation template, follow these steps:

1. Open the AWS Management Console and navigate to CodePipeline.
2. Click on "Create pipeline" and provide a name for your pipeline.
3. Select "GitHub" as the source provider and connect to your GitHub account.
4. Choose the repository and branch to use for the pipeline.
5. For the build stage, select "AWS CodeBuild" and create a new build project with the necessary settings.
   - Set the environment variable `S3_BUCKET_ARTIFACTS` with the name of the S3 bucket you created to store the artifacts for the deployment.
   - Choose the option "Use buildspec file" to automatically search for the `buildspec.yml` file in the root of the repository.
6. Save the pipeline configuration.

## Assigning Permissions to CodeBuild Project

Before executing the pipeline, you need to assign a role to the CodeBuild project with the necessary permissions to create, update, and read the required resources in AWS. This role requires administrative permissions to list, read, create, and delete resources in the following services:

- EC2
- IAM
- Lambda
- Elastic Load Balancing (ELB)
- Amazon RDS
- Amazon S3
- AWS Secrets Manager
- Amazon EventBridge
- Permissions to GetParameter and GetParameters in AWS Systems Manager Parameter Store.

## Update Database Credentials

Before deploying the CloudFormation template, you need to create the following secrets with their respective values in your environment:

- `dbInstanceIdentifier`: This secret should contain the identifier of the database instance.
- `username`: This secret should contain the username for the database.
- `password`: This secret should contain the password for the database.

Make sure to provide the correct values for each secret.

The CloudFormation template (teststack.yaml) includes a Lambda function that handles automatic password updates for the database. This Lambda function is responsible for updating the password in the database whenever it is changed in the associated Secrets Manager. There is no need to perform any additional steps for this feature as it is already implemented in the template.

To ensure the database parameter values in the CloudFormation template utilize the secret values, make sure they reference the appropriate Secrets Manager parameters.

With this setup, the database credentials will be automatically updated using the defined secrets and the provided Lambda function in the CloudFormation template.



## Viewing CodePipeline Execution Status in GitHub Actions

To view the execution status of AWS CodePipeline in GitHub Actions, follow these steps:

1. Authenticate AWS CLI locally using credentials that have permissions to create roles, policies, and an identity provider.
2. Execute the `secrets.sh` script locally to set up the required environment variables. This script will prompt you to enter the name of the role in the `ROLE_NAME` environment variable and the name of the policy in the `POLICY_NAME` environment variable.
3. Execute the create_provider.sh script in your local environment to create the identity provider and the role for assuming. This script will utilize the ROLE_NAME and POLICY_NAME environment variables to create the identity provider and the associated role with the policy.
The identity provider allows GitHub Actions to assume the role and access the CodePipeline execution status information.

4. Once the identity provider is set up, navigate to your GitHub repository and go to the "Settings" tab.
5. In the left sidebar, click on "Secrets" to access the repository's secrets configuration.
6. Create the following secrets in GitHub by clicking on "New repository secret" and entering the corresponding values:
   - `ARN_ROLE_TO_ASSUME`: This secret should contain the ARN (Amazon Resource Name) of the role you created in the previous step.
   - `CODEPIPELINE_NAME`: This secret should contain the name of your CodePipeline pipeline.
   - `REGION`: This secret should contain the AWS region where your CodePipeline is configured.
7. Now you are ready to use GitHub Actions to view the execution status of your CodePipeline. You can configure GitHub Actions workflows to provide real-time information about the status of your pipeline.


## Deploy using CLI

Follow these steps to deploy the resources using the CloudFormation stack:

1. Clone the repository: `git clone <repository-url>`.
2. Review the `teststack.yaml` file and make the necessary modifications according to your requirements.
3. Deploy the stack using the AWS CLI command: `aws cloudformation create-stack --stack-name <stack-name> --template-body file://stacks/teststack.yaml --capabilities CAPABILITY_NAMED_IAM`.
4. Wait for the deployment to complete and verify it in the AWS console.


## Contribution

If you wish to contribute to the project, follow these guidelines:

1. Fork the repository and clone your own copy locally.
2. Create a new branch for your changes: `git checkout -b branch-name`.
3. Make the changes and commit them with descriptive messages.
4. Submit a pull request explaining the changes made.

## Additional Notes

- Ensure that you properly configure the necessary roles and permissions for CodePipeline and CodeBuild to access the required resources.
- For more information on using CodePipeline and CodeBuild, refer to the official AWS documentation.

## License

This project is distributed under the MIT License. See the `LICENSE` file for more details.
