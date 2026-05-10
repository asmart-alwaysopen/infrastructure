pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  parameters {
    choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'production'], description: 'Terraform environment value (TF_VAR_environment).')
    choice(name: 'ACTION', choices: ['plan', 'apply'], description: 'Run plan only, or plan + apply.')
    string(name: 'AWS_REGION', defaultValue: 'us-east-1', description: 'AWS region used by Terraform (TF_VAR_aws_region).')
    string(name: 'AWS_CREDENTIALS_ID', defaultValue: 'aws-jenkins', description: 'Jenkins AWS credentials ID for Terraform.')
  }

  environment {
    TF_IN_AUTOMATION = 'true'
    TF_INPUT         = '0'
    TF_CLI_ARGS      = '-no-color'
    TF_VAR_environment = "${params.ENVIRONMENT}"
    TF_VAR_aws_region  = "${params.AWS_REGION}"
    TF_DIR           = 'terraform'
    PLAN_FILE        = 'tfplan.binary'
    PLAN_TEXT_FILE   = 'tfplan.txt'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Resolve Terraform Directory') {
      steps {
        script {
          if (fileExists('infrastructure/terraform/main.tf')) {
            env.TF_DIR = 'infrastructure/terraform'
          } else if (fileExists('terraform/main.tf')) {
            env.TF_DIR = 'terraform'
          } else {
            error('Could not find terraform directory. Expected infrastructure/terraform or terraform in workspace.')
          }
          echo "Using Terraform directory: ${env.TF_DIR}"
        }
      }
    }

    stage('Terraform Version') {
      steps {
        sh 'terraform version'
      }
    }

    stage('Terraform Init') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: params.AWS_CREDENTIALS_ID,
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh '''
            set -euo pipefail
            : "${TF_DIR:=terraform}"
            terraform -chdir="${TF_DIR}" init -reconfigure
          '''
        }
      }
    }

    stage('Terraform Format + Validate') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: params.AWS_CREDENTIALS_ID,
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh '''
            set -euo pipefail
            : "${TF_DIR:=terraform}"
            terraform -chdir="${TF_DIR}" fmt -check -recursive
            terraform -chdir="${TF_DIR}" validate
          '''
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: params.AWS_CREDENTIALS_ID,
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh '''
            set -euo pipefail
            : "${TF_DIR:=terraform}"
            terraform -chdir="${TF_DIR}" plan -out="${PLAN_FILE}"
            terraform -chdir="${TF_DIR}" show "${PLAN_FILE}" > "${PLAN_TEXT_FILE}"
          '''
        }
      }
    }

    stage('Terraform Apply') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        input message: "Apply Terraform changes for '${params.ENVIRONMENT}'?"
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: params.AWS_CREDENTIALS_ID,
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh '''
            set -euo pipefail
            : "${TF_DIR:=terraform}"
            terraform -chdir="${TF_DIR}" apply -auto-approve "${PLAN_FILE}"
          '''
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: "${env.TF_DIR ?: 'terraform'}/tfplan.*", allowEmptyArchive: true
    }
  }
}
