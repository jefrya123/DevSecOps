pipeline {
    agent any
    environment {
        CONTAINER_NAME = "my-html-container"
        IMAGE_NAME = "my-html-app"
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Build') {
            steps {
                script {
                    sh '''
                    # Build the Docker image
                    docker build -t ${IMAGE_NAME} .
                    '''
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    sh '''
                    # Stop and remove the container if it exists
                    docker ps -q --filter "name=${CONTAINER_NAME}" | xargs -r docker stop
                    docker ps -a -q --filter "name=${CONTAINER_NAME}" | xargs -r docker rm
                    
                    # Stop and remove any container using port 8081
                    docker ps -q --filter "publish=8081" | xargs -r docker stop
                    docker ps -a -q --filter "publish=8081" | xargs -r docker rm
                    
                    # Start the new container
                    docker run -d -p 8081:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}
                    sleep 5

                    # Get the container's IP and test
                    container_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CONTAINER_NAME})
                    echo "Container IP: $container_ip"
                    response=$(curl -o /dev/null -s -w '%{http_code}' http://$container_ip:80)
                    echo "Response code: $response"

                    # Fail if the response is not 200
                    if [ "$response" != "200" ]; then
                        echo "Test failed. Expected HTTP 200 but got $response"
                        exit 1
                    fi
                    '''
                }
            }
        }
        stage('SAST - SonarQube Analysis') {
            steps {
                echo "Static Application Security Testing (SAST) with SonarQube..."
                // Add SonarQube commands here
            }
        }
        stage('Security Scan') {
            steps {
                script {
                    sh '''
                    # Run a security scan on the built image
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image ${IMAGE_NAME}
                    '''
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    sh '''
                    # Cleanup and prepare for deployment
                    docker-compose down || true
                    docker ps -q --filter "name=${CONTAINER_NAME}" | xargs -r docker stop
                    docker ps -a -q --filter "name=${CONTAINER_NAME}" | xargs -r docker rm
                    sleep 5

                    # Deploy the application using Docker Compose
                    docker-compose up -d
                    '''
                }
            }
        }
    }
    post {
        always {
            script {
                sh '''
                # Ensure cleanup after pipeline execution
                docker ps -q --filter "name=${CONTAINER_NAME}" | xargs -r docker stop
                docker ps -a -q --filter "name=${CONTAINER_NAME}" | xargs -r docker rm
                '''
            }
            echo "Pipeline completed."
        }
    }
}
