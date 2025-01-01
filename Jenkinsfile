pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                script {
                    // Build the Docker image
                    sh 'docker build -t my-html-app .'
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    // Cleanup any existing container with the same name or port
                    sh '''
                    docker ps -q --filter "name=my-html-container" | xargs -r docker stop
                    docker ps -a -q --filter "name=my-html-container" | xargs -r docker rm
                    docker ps -q --filter "publish=8081" | xargs -r docker stop
                    docker ps -a -q --filter "publish=8081" | xargs -r docker rm
                    '''

                    // Run the container
                    sh 'docker run -d -p 8081:80 --name my-html-container my-html-app'

                    // Wait for the container to initialize
                    sh 'sleep 5'

                    // Check if the container responds
                    sh '''
                    container_ip=$(docker inspect -f "{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}" my-html-container)
                    echo "Container IP: $container_ip"
                    response=$(curl -o /dev/null -s -w "%{http_code}" http://$container_ip:80)
                    echo "Response code: $response"
                    if [ "$response" != "200" ]; then
                        echo "Test failed: HTTP response code $response"
                        exit 1
                    fi
                    '''
                }
            }
        }

        stage('Security Scan') {
            steps {
                script {
                    // Run Trivy for security scanning
                    sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image my-html-app'
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Deploy the container if needed
                    sh '''
                    docker-compose down
                    docker-compose up -d
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                // Cleanup after the pipeline
                sh '''
                docker ps -q --filter "name=my-html-container" | xargs -r docker stop
                docker ps -a -q --filter "name=my-html-container" | xargs -r docker rm
                '''
            }
        }
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs for details.'
        }
    }
}
