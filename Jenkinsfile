// Jenkinsfile
pipeline {
    agent any
  stages {
      stage('checkout') {
        steps {
          cleanWs()
          checkout scm
        }
      }

      // Run terraform init
      stage('init') {
            steps {
              withAWS(role:'jenkins-deploy') {
                    sh 'terraform init -no-color'
                }
            }
      }
      // Run terraform plan
      stage('plan') {
        steps {
          withAWS(role:'jenkins-deploy') {
              sh 'terraform plan'           
          }
        }
        }
  }
}    

        
        

