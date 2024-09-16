pipeline {
    agent any
    
    stages {
        stage('git') {
            steps {
                dir('vector-role') {
                    git branch: 'main', credentialsId: '8bf3ba0b-b1e8-4dd6-871b-fa6d554a9b78', url: 'https://github.com/nikolay480/vector-role.git'
                }
            }
        }
        stage('molecule') {
            steps {
                   sh 'source /home/jenkins/python310-env/bin/activate'
                   dir('vector-role') {
                       sh 'molecule test'
                   }
            }
        }
    }
}