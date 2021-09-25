pipeline {
  agent { docker { image 'ruby:2.3.1' } }
  stages {
    stage('requirements') {
      steps {
        sh 'gem install bundler -v 1.16.1'
      }
    }
    stage('build') {
      steps {
        sh 'bundle install'
      }
    }
    stage('test') {
      steps {
        sh 'bundle exec rspec'
      }
    }
  }
}
