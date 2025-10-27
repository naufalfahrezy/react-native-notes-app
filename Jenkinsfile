pipeline {
  agent { label 'linux' }

  options {
    ansiColor('xterm')
    timestamps()
  }

  environment {
    // samakan dengan Credentials ID di Jenkins kamu
    REGISTRY_CREDENTIALS = 'dockerhub-credentials'
    // kalau pakai beberapa compose file, bisa dipisah pakai colon: 'docker-compose.yml:docker-compose.prod.yml'
    COMPOSE_FILE = 'docker-compose.yml'
  }

  stages {
    stage('Checkout') {
      steps {
        // Kalau job kamu "Pipeline from SCM", ini aman.
        // Jika job "Pipeline script", ganti ke:
        // git branch: 'main', url: 'https://github.com/naufalfahrezy/react-native-notes-app.git'
        checkout scm
      }
    }

    stage('Verify Docker & Compose') {
      steps {
        sh '''
          set -e
          docker version
          # Cek docker compose v2 (preferred). Jika tidak ada, fallback ke docker-compose (v1).
          if docker compose version >/dev/null 2>&1; then
            echo "Using docker compose v2"
          elif docker-compose version >/dev/null 2>&1; then
            echo "Using docker-compose v1"
            alias docker='docker' # no-op
            alias docker\ compose='docker-compose'
          else
            echo "ERROR: docker compose / docker-compose tidak ditemukan"
            exit 1
          fi
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
          # --pull agar selalu ambil base image terbaru (opsional)
          docker compose -f "$COMPOSE_FILE" build --pull
        '''
      }
    }

    stage('Push to Docker Hub') {
      steps {
        sh 'docker compose -f "$COMPOSE_FILE" push'
      }
    }

    // (Opsional) Tambah tag berdasarkan tanggal & commit
    stage('Tag extra (optional)') {
      when { expression { return fileExists('docker-compose.yml') } }
      steps {
        sh '''
          set -e
          COMMIT_SHORT=$(git rev-parse --short HEAD)
          DATE_TAG=$(date +%Y%m%d-%H%M)

          # CONTOH: kalau di compose service kamu men-tag image "username/repo:latest",
          # di sini kita bikin tag tambahan :$DATE_TAG-$COMMIT_SHORT.
          # Ganti "service1" dan nama image di bawah sesuai compose kamu.
          # Contoh untuk satu service bernama "app" dengan image "naufalfahrezy/rn-notes:latest":

          IMG=$(docker compose -f "$COMPOSE_FILE" config | awk '/image:/ {print $2}' | head -n1)
          if [ -n "$IMG" ]; then
            echo "Base image dari compose: $IMG"
            docker tag "$IMG" "${IMG%%:*}:$DATE_TAG-$COMMIT_SHORT" || true
            docker push "${IMG%%:*}:$DATE_TAG-$COMMIT_SHORT" || true
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
