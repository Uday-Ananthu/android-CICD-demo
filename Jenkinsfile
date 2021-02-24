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
        stage('LintAnalyser') {
            steps {
                script {
                    dir('BasicSample') {
                        sh "${env.ANDROID_LINT_COMMAND}"
                    }
                }
            }
        }
        stage('UITests') {
            steps {
                script {
                    dir('BasicSample') {
                        sh "${env.ANDROID_UI_TEST_COMMAND}"
                    }
                }
            }
        }
        stage('GithubRelease') {
            steps {
                script {
                    dir('BasicSample') {
                        sh "${env.ANDROID_PACKGER_COMMAND}"
                        def release_name = "Release-0.0.${env.BUILD_NUMBER}"
                        def tag_name = "v0.0.${env.BUILD_NUMBER}"
                        def release_description = "Initial Release"
                        def commit_sha = "main"
                        def upload_assets = "${env.RELEASE_ASSETS_DIR}"
                        if (isReleaseBuild()) {
                            withCredentials([usernamePassword(credentialsId: 'github_api_token', passwordVariable: 'GITHUB_TOKEN', usernameVariable: 'GITHUB_USER')]) {
                                sh "bundle install && bundle exec fastlane githubRelease release_name:${release_name} tag_name:${tag_name} release_description:'${release_description}' commit_sha:${commit_sha} upload_assets:${upload_assets}"
                            }
                        } else {
                            echo "[Info] Skipping APK release to GITHUB"
                        }
                    }
                }
            }
            post {
                success {
                    script {
                        // Archive the APKs so that they can be downloaded from Jenkins
                        echo 'Archiving APKs...'
                        archiveArtifacts '**/*.zip'
                    }
                }
            }
        } 
    }
    post {
        failure {
            script {
                // Notify developers in relevant possible ways
                // 1. Email, 2. Slack/Teams/WebEx
                echo 'Job failed, sending notification to developers....'
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
        env.ANDROID_LINT_COMMAND = 'gradle lintRelease'
        env.ANDROID_UI_TEST_COMMAND = 'gradle deviceCheck deviceAndroidTest'
        env.ANDROID_PACKGER_COMMAND = 'gradle zipApksForRelease'
        // Except Release Type of 'Release' everything for now is considered as Debug Build
    } else {
        env.ANDROID_BUILD_COMMAND = 'gradle clean assembleDebug'
        env.ANDROID_UNIT_TEST_COMMAND = 'gradle assembleDebugUnitTest testDebugUnitTest'
        env.ANDROID_LINT_COMMAND = 'gradle lintDebug'
        env.ANDROID_UI_TEST_COMMAND = 'gradle deviceCheck deviceAndroidTest'
        env.ANDROID_PACKGER_COMMAND = 'gradle zipApksForDebug'
    }
}

/**
 * Checking if the current build is a release build or not
 */
def isReleaseBuild() {
    return "${params.RELEASE_TYPE}".equalsIgnoreCase("Release")
}
