// Jenkinsfile
pipeline {
    agent any
  stages {
      stage('checkout') {
        node {
          cleanWs()
          checkout scm
        }
      }
      // Run terraform init
      stage('init') {
            steps {
                    sh 'terraform init -no-color'
                }
            }
      // Run terraform plan
      stage('plan') {
        steps {
              sh 'terraform plan'           
          }
        }
  }
}    

        
        

