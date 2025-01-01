pipeline {
    agent any
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t my-html-app .'
            }
        }
        stage('Test') {
            steps {
                sh '''
                docker ps -q --filter name=my-html-container | xargs -r docker stop
                docker ps -a -q --filter name=my-html-container | xargs -r docker rm
                docker run -d -p 8081:80 --name my-html-container my-html-app
                sleep 5
                container_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' my-html-container)
                response=$(curl -o /dev/null -s -w "%{http_code}" http://$container_ip:80)
                echo "Response code: $response"
                docker stop my-html-container
                '''
            }
        }
        stage('SAST - SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') { // Configure SonarQube in Jenkins
                    sh '''
                    sonar-scanner \
                      -Dsonar.projectKey=devsecops \
                      -Dsonar.sources=. \
                      -Dsonar.host.url=http://localhost:9000 \
                      -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }
        stage('Security Scan') {
            steps {
                sh '''
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image my-html-app
                '''
            }
        }
        stage('Deploy') {
            steps {
                sh '''
                docker-compose down
                docker-compose up -d
                '''
            }
        }
    }
    post {
        always {
            sh '''
            docker ps -q --filter name=my-html-container | xargs -r docker stop
            docker ps -a -q --filter name=my-html-container | xargs -r docker rm
            '''
            echo 'Pipeline completed.'
        }
    }
}
