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
                    // Dynamically find a free port
                    def freePort = sh(script: """
                        seq 8000 9000 | while read port; do
                            ss -tln | grep -q ":\\$port" || { echo \\$port; break; }
                        done
                    """, returnStdout: true).trim()

                    // Run the container on the free port
                    def containerId = sh(script: "docker run -d -p ${freePort}:80 my-app-image", returnStdout: true).trim()

                    try {
                        // Allow the container some time to initialize
                        sh "sleep 5"

                        // Check if the site is up by verifying HTTP status code
                        def statusCode = sh(script: "curl -o /dev/null -s -w '%{http_code}' http://localhost:${freePort}", returnStdout: true).trim()
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
                sh "docker-compose down || true" // Stop any existing deployment
                sh "docker-compose up -d"      // Start the new deployment
            }
        }
    }
}
