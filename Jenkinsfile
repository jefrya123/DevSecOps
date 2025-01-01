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
                    // Run the container
                    def containerId = sh(script: "docker run -d -p 8081:80 my-app-image", returnStdout: true).trim()

                    try {
                        // Allow the container some time to initialize
                        sh "sleep 5"

                        // Check if the site is up by verifying HTTP status code
                        sh """
                        status_code=\$(curl -o /dev/null -s -w "%{http_code}" http://localhost:8081)
                        if [ "\$status_code" -ne 200 ]; then
                            echo "Error: Unexpected status code \$status_code"
                            exit 1
                        fi
                        echo "Site is up and responded with HTTP 200"
                        """

                        // Optionally, check for non-empty content
                        sh """
                        content=\$(curl -s http://localhost:8081)
                        if [ -z "\$content" ]; then
                            echo "Error: Site response is empty"
                            exit 1
                        fi
                        echo "Site responded with content"
                        """
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
                sh "docker-compose down || true" // Stop any existing deployment
                sh "docker-compose up -d"      // Start the new deployment
            }
        }
    }
}
