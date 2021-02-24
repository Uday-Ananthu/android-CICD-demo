pipeline {
    agent {
        docker {
            image 'android-image:latest'
        }
    }
    stages {
        stage('SCM-Checkout') {
            steps {
                cleanWs()
                checkout scm
            }
        }
}
