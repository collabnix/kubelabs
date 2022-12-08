# Jenkins CI for Kubernetes

## Requirements

To start off, you need a repository. A simple GitHub repo should do just fine.

For this lab, we will be using a simple Java application. Feel free to use any Java application that supports maven (which we will be using as a build tool). For convenience, you can get Maven to generate a template application for you. Make sure you have Maven installed, and then use:

```
mvn archetype:generate
-DgroupId = com.companyname.ci 
-DartifactId = ciarchetype 
-DarchetypeArtifactId = maven-archetype-quickstart 
-DinteractiveMode = false
```

This will create an application complete with a Java class and a JUnit test class (which we will be using to run unit tests on Jenkins). You can add something to the existing application if you like, but there is no explicit need to do so as the application will have everything we need to get a sample Jenkins job up and running.

Now, start Jenkins. Note that if this is the first time you are starting Jenkins, you will have to follow the starting instructions and use the admin password. You can also select to install all the default plugins, or manually pick only the ones we need. We will be needing all the base pipeline as code plugins as well as GitHub integration plugins (as that is where we will be hosting our code). Don't worry if you forget something. We can always install plugins later.

With Jenkins setup, let's put that aside for a moment and focus on getting the Java application running. Before you do anything, go into the directory where the `pom.xml` is located, and run:

```
mvn clean install
```

Ensure that the project builds fine. If everything looks good to go, it's time to look at the Jenkins portion of the code.

Let's start by creating a Jekinsfile. This is what will hold your entire Jenkins configuration. For starters, let's come up with a simple pipeline. First checkout the repo, then build it:

```yaml
pipeline {
    agent any

    stages {
        stage('checkout') {
            steps {
                checkout([$class: 'GitSCM',
                        branches: [[name: 'master']],
                        userRemoteConfigs: [[credentialsId: '<yourcredentials>',
                        url: 'https://github.com/<repo_url>']]])
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
```

The last part of the file is the `always` block, which specifies code that needs to run at the end of the pipeline regardless of the outcomes (success, fail, etc...). In this case, we are telling the build to clean the workspace at the end regardless of the outcome.

The first thing to note is that running jobs on your master node can introduce security concerns. For example, anyone with access to your Jenkins pipeline will be able to create a job that runs malicious bash scripts. When this job is executed, the code will run on the host machine.

So the best practice with Jenkins is not to have any jobs running on the master node (as well as making the master node unschedulable). Then, we need to introduce a new agent which we can use to run Jenkins slave nodes on. 