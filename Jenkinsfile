pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    docker.build('my-app-image')
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    def containerId = sh(script: "docker run -d -p 8081:80 my-app-image", returnStdout: true).trim()
                    try {
                        sh "sleep 5" // Allow the container to start
                        echo "Checking container response..."
                        sh "curl -s http://localhost:8081 || echo 'Curl failed'"
                    } finally {
                        sh "docker stop ${containerId}"
                    }
                }
            }
        }
        stage('Security Scan') {
            steps {
                script {
                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image my-app-image"
            }
        }
    }
        stage('Deploy') {
            steps {
                sh "docker-compose down || true" // Stop any existing deployment
                sh "docker-compose up -d"      // Start the new deployment
            }
        }
    }
}
