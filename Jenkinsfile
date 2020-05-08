pipeline {
    agent {
        node {
            label 'multi-arch-docker-release'
            customWorkspace "${JOB_NAME}/${BUILD_NUMBER}"
        }
    }

    parameters {
        string(name: 'MANAGEMENT_CENTER_DOCKER_TAG', description: 'Management Center Docker Tag')
    }

    stages {
        stage('Log into Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'devopshazelcast-dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh "docker login --username ${USERNAME} --password ${PASSWORD}"
                }
            }
        }
        stage('Build and push "hazelcast/management-center" image') {
            steps {
                dir("./") {
                    script {
                        sh "docker buildx build -t hazelcast/management-center:${MANAGEMENT_CENTER_DOCKER_TAG} --platform=linux/arm64,linux/amd64,linux/ppc64le,linux/s390x . --push"
                    }

                }
            }
        }
    }
}
