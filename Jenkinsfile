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
                        sh "curl -s http://localhost:8080 | grep 'Welcome to the DevSecOps Pipeline'"
                    } finally {
                        sh "docker stop ${containerId}"
                    }
                }
            }
        }
        stage('Security Scan') {
            steps {
                echo 'Scanning for vulnerabilities...'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
            }
        }
    }
}
