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
                        sh "sleep 10"

                        // Inspect container logs for debugging
                        sh "docker logs ${containerId}"

                        // Retry the curl command to check if the service is up
                        def statusCode = sh(script: """
                            for i in {1..5}; do
                                status=\$(curl -o /dev/null -s -w '%{http_code}' http://localhost:8081)
                                if [ "\$status" -eq 200 ]; then
                                    echo \$status
                                    exit 0
                                fi
                                sleep 2
                            done
                            exit 1
                        """, returnStdout: true).trim()

                        echo "Service responded with HTTP status: ${statusCode}"
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
