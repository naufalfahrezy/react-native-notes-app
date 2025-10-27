pipeline {
  agent any  // jalan di node Windows juga ok

  options {
    timestamps()
  }

  environment {
    REGISTRY_CREDENTIALS = 'dockerhub-credentials' // ganti kalau ID creds beda
    COMPOSE_FILE = 'docker-compose.yml'            // ganti kalau pakai file lain
  }

  stages {
    stage('Checkout') {
      steps {
        // Kalau job ini "Pipeline from SCM", ini cukup.
        // Jika "Pipeline script", ganti ke:
        // git branch: 'main', url: 'https://github.com/naufalfahrezy/react-native-notes-app.git'
        checkout scm
      }
    }

    stage('Verify Docker & Compose') {
      steps {
        bat '''
        @echo off
        docker version || exit /b 1

        rem --- Deteksi compose v2 (docker compose) atau v1 (docker-compose)
        docker compose version >NUL 2>&1
        if %ERRORLEVEL%==0 (
          echo docker compose> .compose_cmd
          echo Using docker compose v2
          goto :eof
        )
        docker-compose --version >NUL 2>&1
        if %ERRORLEVEL%==0 (
          echo docker-compose> .compose_cmd
          echo Using docker-compose v1
          goto :eof
        )
        echo ERROR: docker compose / docker-compose not found
        exit /b 1
        '''
      }
    }

    stage('Login to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.REGISTRY_CREDENTIALS, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          bat 'echo %PASS% | docker login -u %USER% --password-stdin'
        }
      }
    }

    stage('Build Docker Images') {
      steps {
        bat '''
        @echo off
        set /p COMPOSE=<.compose_cmd
        if "%COMPOSE%"=="" (echo Failed to read compose cmd & exit /b 1)
        rem --pull opsional (ambil base image terbaru)
        %COMPOSE% -f "%COMPOSE_FILE%" build --pull
        '''
      }
    }

    stage('Push to Docker Hub') {
      steps {
        bat '''
        @echo off
        set /p COMPOSE=<.compose_cmd
        %COMPOSE% -f "%COMPOSE_FILE%" push
        '''
      }
    }
  }

  post {
    always {
      bat 'docker logout || ver >nul'
      cleanWs()
    }
  }
}
