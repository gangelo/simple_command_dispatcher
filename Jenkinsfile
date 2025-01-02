pipeline {
  agent { docker { image 'ruby:3.2.6' } }
  stages {
    stage('requirements') {
      steps {
        sh 'gem install bundler -v 2.5.6'
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
