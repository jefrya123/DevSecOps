pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                script {
                    sh 'docker build -t my-html-app .'
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    // Stop and remove any existing container on port 8081
                    sh '''
                    docker ps -q --filter "publish=8081" | xargs -r docker stop
                    docker ps -a -q --filter "publish=8081" | xargs -r docker rm
                    '''

                    // Start the container
                    sh 'docker run -d -p 8081:80 --name my-html-container my-html-app'

                    // Wait for the container to start
                    sh 'sleep 5'

                    // Get the bridge network IP for the container
                    sh '''
                    container_ip=$(docker inspect -f "{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}" my-html-container)
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
                    sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image my-html-app'
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Clean up the old container if it exists
                    sh 'docker ps -q --filter "name=my-html-container" | xargs -r docker stop'
                    sh 'docker ps -a -q --filter "name=my-html-container" | xargs -r docker rm'

                    // Run the container for deployment
                    sh 'docker run -d -p 8081:80 --name my-html-container my-html-app'
                }
            }
        }
    }
}
