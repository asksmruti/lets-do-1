/* Following pipe-line will - 
1. Build and push artifact into /mnt/artifact/<build-number> directory on Jenkins
2. Deploy the artifact into remote app server in private subnet
3. Failure notification, test report generation, webhook etc.. are not in scope 
*/

pipeline {
  agent any
  environment {
    M2_HOME="/opt/maven"
    PATH="${M2_HOME}/bin:${PATH}"
    ARTIFACTORY_PATH="/mnt/artefact/${env.BUILD_NUMBER}"
    APP_NAME="spring-petclinic"
  }

  stages {
     stage('Checkout') {
        steps {
          git 'https://github.com/spring-projects/spring-petclinic'
        }
     }
     stage('Build') {
        steps {
           sh './mvnw package'
           sh 'mkdir -p ${ARTIFACTORY_PATH}'
           sh 'cp target/${APP_NAME}-*.jar ${ARTIFACTORY_PATH}/${APP_NAME}.jar'
       }
     }
     stage('Deploy') {
        steps {
           sh 'cd /tmp/ansible/ && ansible-playbook -i hosts.ini --extra-vars "artifact_path=${ARTIFACTORY_PATH} app_name=${APP_NAME}.jar http_port=8080" app.yml'
        }
     }
  }
}
