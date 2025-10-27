pipeline {
  agent { label 'linux' }

  environment {
    IMAGE_NAME   = "naufalfahrezy/rn-notes"   // ganti sesuai repo Docker Hub kamu
    COMMIT_SHORT = ""
    DATE_TAG     = ""
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'git --version || true' // info git di agent
      }
    }

    stage('Verify Docker') {
      steps {
        sh 'docker version'
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
          COMMIT_SHORT=$(git rev-parse --short HEAD)
          DATE_TAG=$(date +%Y%m%d-%H%M)
          echo $COMMIT_SHORT > .commit_short
          echo $DATE_TAG > .date_tag

          docker tag $IMAGE_NAME:dev $IMAGE_NAME:dev-$DATE_TAG-$COMMIT_SHORT || true
          if docker image inspect $IMAGE_NAME:web >/dev/null 2>&1; then
            docker tag $IMAGE_NAME:web $IMAGE_NAME:web-$DATE_TAG-$COMMIT_SHORT
          fi
        '''
      }
    }

    stage('Login & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push $IMAGE_NAME:dev
            if docker image inspect $IMAGE_NAME:web >/dev/null 2>&1; then
              docker push $IMAGE_NAME:web
            fi

            DATE_TAG=$(cat .date_tag)
            COMMIT_SHORT=$(cat .commit_short)
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
