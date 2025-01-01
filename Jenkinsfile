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
                    // Clean up any existing containers using port 8081
                    sh """
                        docker ps -q --filter "publish=8081" | xargs -r docker stop
                        docker ps -a -q --filter "publish=8081" | xargs -r docker rm
                    """

                    // Run the container on port 8081
                    def containerId = sh(script: "docker run -d -p 8081:80 my-app-image", returnStdout: true).trim()

                    try {
                        // Allow the container some time to initialize
                        sh "sleep 5"

                        // Check if the site is up by verifying HTTP status code
                        def statusCode = sh(script: "curl -o /dev/null -s -w '%{http_code}' http://localhost:8081", returnStdout: true).trim()
                        if (statusCode != '200') {
                            error "Site did not return HTTP 200. Got: ${statusCode}"
                        }

                        echo "Site is up and responded with HTTP 200"
                    } finally {
                        // Stop the container
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
                script {
                    // Ensure clean slate
                    sh "docker-compose down || true"
                    // Deploy the application
                    sh "docker-compose up -d"
                }
            }
        }
    }
}
