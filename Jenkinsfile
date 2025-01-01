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
                    def freePort = sh(script: "comm -23 <(seq 8000 9000) <(ss -tln | awk '{print \$4}' | grep -oE '[0-9]+\$' | sort -n | uniq)", returnStdout: true).trim().split('\n')[0]

                    // Run the container on the free port
                    def containerId = sh(script: "docker run -d -p ${freePort}:80 my-app-image", returnStdout: true).trim()

                    try {
                        // Allow the container some time to initialize
                        sh "sleep 5"

                        // Check if the site is up by verifying HTTP status code
                        sh """
                        status_code=\$(curl -o /dev/null -s -w "%{http_code}" http://localhost:${freePort})
                        if [ "\$status_code" -ne 200 ]; then
                            echo "Error: Unexpected status code \$status_code"
                            exit 1
                        fi
                        echo "Site is up and responded with HTTP 200"
                        """

                        // Optionally, check for non-empty content
                        sh """
                        content=\$(curl -s http://localhost:${freePort})
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
