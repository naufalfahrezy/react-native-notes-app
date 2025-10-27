pipeline {
  agent any

  environment {
    IMAGE_NAME = "<dockerhub-username>/rn-notes"
    COMMIT_SHORT = "${env.GIT_COMMIT?.take(7)}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build dev image') {
      steps {
        sh 'docker build -t $IMAGE_NAME:dev --target dev .'
      }
    }

    stage('(Optional) Build web image') {
      when { expression { return fileExists('app.json') } }
      steps {
        sh 'docker build -t $IMAGE_NAME:web --target web .'
      }
    }

    stage('Tag with commit/date') {
      steps {
        sh '''
          DATE_TAG=$(date +%Y%m%d-%H%M)
          docker tag $IMAGE_NAME:dev $IMAGE_NAME:dev-$DATE_TAG-$COMMIT_SHORT
          if docker image inspect $IMAGE_NAME:web >/dev/null 2>&1; then
            docker tag $IMAGE_NAME:web $IMAGE_NAME:web-$DATE_TAG-$COMMIT_SHORT
          fi
          echo $DATE_TAG > .date_tag
        '''
      }
    }

    stage('Login & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push $IMAGE_NAME:dev
            if docker image inspect $IMAGE_NAME:web >/dev/null 2>&1; then
              docker push $IMAGE_NAME:web
            fi

            DATE_TAG=$(cat .date_tag)
            docker push $IMAGE_NAME:dev-$DATE_TAG-$COMMIT_SHORT || true
            if docker image inspect $IMAGE_NAME:web >/dev/null 2>&1; then
              docker push $IMAGE_NAME:web-$DATE_TAG-$COMMIT_SHORT || true
            fi
          '''
        }
      }
    }
  }

  post {
    always {
      sh 'docker logout || true'
      cleanWs()
    }
  }
}
