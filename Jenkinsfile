pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_KEY_ID_P')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_KEY_P')
    }
    parameters {
        choice(
            choices: ['plan', 'apply', 'show', 'preview-destroy', 'destroy'],
            description: 'Terraform action to apply',
            name: 'action')
        choice(
            choices: ['dev', 'test', 'prod'],
            description: 'deployment environment',
            name: 'ENVIRONMENT')
        string(defaultValue: "ap-south-1", description: 'aws region', name: 'AWS_REGION')
        string(defaultValue: "demo", description: 'application system identifier', name: 'ASI')
    }
    stages {
        stage('init') {
            steps {
                withCredentials([string(credentialsId: 'AWS_KEY_ID_P', variable:  'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_KEY_P', variable:'AWS_SECRET_ACCESS_KEY')]) {
                    sh 'pwd;cd tfdeploy ;terraform init -no-color'
                }
            }
        }
        stage('validate') {
            steps {
                sh 'pwd;cd tfdeploy ;terraform validate -no-color'
            }
        }
        stage('plan') {
            when {
                expression { params.action == 'plan' || params.action == 'apply' }
            }
            steps {
                sh 'pwd;cd tfdeploy ;terraform plan -no-color -input=false -out=tfplan'
            }
        }
        stage('approval') {
            when {
                expression { params.action == 'apply'}
            }
            steps {
                sh 'pwd;cd tfdeploy ;terraform show -no-color tfplan > tfplan.txt'
                script {
                    def plan = readFile 'tfdeploy/tfplan.txt'
                    input message: "Apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }
        stage('apply') {
            when {
                expression { params.action == 'apply' }
            }
            steps {
                sh 'pwd;cd tfdeploy ;terraform apply -no-color -input=false tfplan'
            }
        }
        stage('show') {
            when {
                expression { params.action == 'show' }
            }
            steps {
                sh 'pwd;cd tfdeploy ;terraform show -no-color'
            }
        }
        stage('preview-destroy') {
            when {
                expression { params.action == 'preview-destroy' || params.action == 'destroy'}
            }
            steps {
                sh 'pwd;cd tfdeploy ;terraform plan -no-color -destroy -out=tfplan'
                sh 'pwd;cd tfdeploy ;terraform show -no-color tfplan > tfplan.txt'
            }
        }
        stage('destroy') {
            when {
                expression { params.action == 'destroy' }
            }
            steps {
                script {
                    def plan = readFile 'tfdeploy/tfplan.txt'
                    input message: "Delete the stack?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
                sh 'pwd;cd tfdeploy ;terraform destroy -auto-approve'
            }
        }
    }
}