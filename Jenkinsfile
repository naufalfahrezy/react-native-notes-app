pipeline {
  agent { label 'linux' }   // pastikan node Linux-mu berlabel 'linux'

  options {
    ansiColor('xterm')
    timestamps()
  }

  environment {
    REGISTRY_CREDENTIALS = 'dockerhub-credentials'  // ganti jika ID creds beda
    COMPOSE_FILE = 'docker-compose.yml'             // ubah jika pakai file lain
  }

  stages {
    stage('Checkout') {
      steps {
        // Jika job ini "Pipeline from SCM", ini aman.
        // Kalau job "Pipeline script", kamu bisa ganti ke:
        // git branch: 'main', url: 'https://github.com/naufalfahrezy/react-native-notes-app.git'
        checkout scm
      }
    }

    stage('Verify Docker & Compose') {
      steps {
        sh '''
          set -e
          docker version

          # Tentukan perintah compose yang tersedia (v2 atau v1)
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

    // (Opsional) tambah penandaan berdasarkan tanggal & short SHA
    // Pastikan image di docker-compose.yml sudah punya nama repository (username/repo:tag)
    stage('Tag extra (optional)') {
      when { expression { return fileExists(env.COMPOSE_FILE) } }
      steps {
        sh '''
          set -e
          COMMIT_SHORT=$(git rev-parse --short HEAD)
          DATE_TAG=$(date +%Y%m%d-%H%M)

          # Ambil image pertama dari compose (kalau multi-service, silakan kembangkan sesuai kebutuhan)
          IMG=$(docker compose -f "$COMPOSE_FILE" config | awk '/image:/ {print $2}' | head -n1 || true)

          if [ -n "$IMG" ]; then
            echo "Base image dari compose: $IMG"
            NEW_TAG="${IMG%%:*}:$DATE_TAG-$COMMIT_SHORT"
            docker tag "$IMG" "$NEW_TAG" || true
            docker push "$NEW_TAG" || true
          else
            echo "Tidak menemukan field 'image:' di compose. Lewati pen-tag-an opsional."
          fi
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
