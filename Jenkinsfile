pipeline {
    agent any

    environment {
        IMAGE_NAME = 'naufalfahrezy/rn-notes'
        REGISTRY = 'https://index.docker.io/v1/'
        REGISTRY_CREDENTIALS = '24'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:BUILD-${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry(REGISTRY, REGISTRY_CREDENTIALS) {
                        def tag = "${IMAGE_NAME}:BUILD-${env.BUILD_NUMBER}"
                        docker.image(tag).push()
                        docker.image(tag).push('latest')
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Selesai proses CI/CD'
        }
    }
}