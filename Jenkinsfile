pipeline {
  agent { label 'linux' }   // gunakan node Linux

  options {
    timestamps()
    // Hapus ansiColor karena plugin belum ada di instance kamu
  }

  environment {
    REGISTRY_CREDENTIALS = 'dockerhub-credentials'  // sesuaikan jika beda
    COMPOSE_FILE = 'docker-compose.yml'             // ubah bila pakai file lain
  }

  stages {
    stage('Checkout') {
      steps {
        // Jika job "Pipeline from SCM", ini aman.
        // Kalau "Pipeline script", ganti ke:
        // git branch: 'main', url: 'https://github.com/naufalfahrezy/react-native-notes-app.git'
        checkout scm
      }
    }

    stage('Verify Docker & Compose') {
      steps {
        sh '''
          set -e
          docker version

          # Tentukan perintah compose (v2 atau v1) TANPA alias
          if docker compose version >/dev/null 2>&1; then
            COMPOSE="docker compose"
            echo "Using docker compose v2"
          elif command -v docker-compose >/dev/null 2>&1; then
            COMPOSE="docker-compose"
            echo "Using docker-compose v1"
          else
            echo "ERROR: docker compose / docker-compose tidak ditemukan"
            exit 1
          fi

          # simpan agar stage lain tinggal baca
          echo "$COMPOSE" > .compose_cmd
        '''
      }
    }

    stage('Login to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.REGISTRY_CREDENTIALS, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          sh 'echo "$PASS" | docker login -u "$USER" --password-stdin'
        }
      }
    }

    stage('Build Docker Images') {
      steps {
        sh '''
          set -e
          COMPOSE=$(cat .compose_cmd)
          # --pull untuk tarik base image terbaru (opsional)
          $COMPOSE -f "$COMPOSE_FILE" build --pull
        '''
      }
    }

    stage('Push to Docker Hub') {
      steps {
        sh '''
          set -e
          COMPOSE=$(cat .compose_cmd)
          $COMPOSE -f "$COMPOSE_FILE" push
        '''
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
