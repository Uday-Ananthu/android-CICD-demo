pipeline {
    agent {
        docker {
            image 'android-image:latest'
        }
    }
    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '7', artifactNumToKeepStr: '7', daysToKeepStr: '7', numToKeepStr: '7')
        timestamps()
        timeout(time: 2, unit: 'HOURS')
        // Stop the build early in case of compile or test failures
        skipStagesAfterUnstable()
        parallelsAlwaysFailFast()
    }
    parameters {
        choice choices: ['Debug', 'Release'], description: 'Choose the type of release', name: 'RELEASE_TYPE'
    }
    environment {
        GRADLE_USER_HOME = "${env.WORKSPACE}"
    }
    stages {
        stage('SCM-Checkout') {
            steps {
                cleanWs()
                checkout scm
            }
        }
        stage('Build') {
            steps {
                script {
                    setBuildCommandsBasedOnReleaseType()
                    dir('BasicSample') {
                        sh "${env.ANDROID_BUILD_COMMAND}"
                    }
                }
            }
        }
        stage('UnitTest') {
            steps {
                script {
                    dir('BasicSample') {
                        sh "${env.ANDROID_UNIT_TEST_COMMAND}"
                    }
                    // Publish Test Reports
                    publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, includes: '**/*.html', keepAll: false, reportDir: '', reportFiles: 'index.html', reportName: 'HTML Report'])
                }
            }
        } 
    }
}

/**
 * Setting the build commands based on the type of the release
 */
def setBuildCommandsBasedOnReleaseType() {
    echo "Is is release build: ${isReleaseBuild()}"
    if (isReleaseBuild()) {
        env.ANDROID_BUILD_COMMAND = 'gradle clean assembleRelease'
        env.ANDROID_UNIT_TEST_COMMAND = 'gradle assembleReleaseUnitTest testReleaseUnitTest'
        // Except Release Type of 'Release' everything for now is considered as Debug Build
    } else {
        env.ANDROID_BUILD_COMMAND = 'gradle clean assembleDebug'
        env.ANDROID_UNIT_TEST_COMMAND = 'gradle assembleDebugUnitTest testDebugUnitTest'
    }
}

/**
 * Checking if the current build is a release build or not
 */
def isReleaseBuild() {
    return "${params.RELEASE_TYPE}".equalsIgnoreCase("Release")
}
