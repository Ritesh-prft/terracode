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
              withAWS(role:'jenkins-deploy', roleArn: 'arn:aws:iam::466515034134:role/jenkins-deploy',roleSessionName: 'jenkins-session'  ) {
                    sh 'terraform init -no-color'
                }
            }
      }
      // Run terraform plan
      stage('plan') {
        steps {
          withAWS(role:'jenkins-deploy', roleArn: 'arn:aws:iam::466515034134:role/jenkins-deploy',roleSessionName: 'jenkins-session') {
              sh 'terraform plan'           
          }
        }
        }
  }
}    

        
        

