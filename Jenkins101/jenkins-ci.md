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

Let's start by creating a Jekinsfile. This is what will hold your entire Jenkins configuration. Create a file called "Jenkinsfile" in the root of your project directory and add the below code into it. First checkout the repo, then build it:

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

This is the Jenkins declarative syntax which is a simpler form code that allows you to get up and running with Jenkins quickly. As you may notice, the above code is pretty self-explanatory. You could also create a Groovy file for complex pipelines and use Groovy code (and libraries). At the start, you specify which node you want to run the pipeline on. `any` signifies that the pipeline should run on any available node (only the one node in this case). The last part of the file is the `always` block, which specifies code that needs to run at the end of the pipeline regardless of the outcomes (success, fail, etc...). In this case, we are telling the build to clean the workspace at the end regardless of the outcome.

At this point, your project directory should look something like this:

```
.
├── dependency-reduced-pom.xml
├── Jenkinsfile
├── mvnw
├── mvnw.cmd
├── pom.xml
├── src
│   ├── main
│   │   └── java
│   │       └── hello
│   │           ├── Greeter.java
│   │           └── HelloWorld.java
│   └── test
│       └── java
│           └── hello
│               └── GreeterTest.java
```

You may also have a `target` folder that got created when you ran `mvn clean install`. This folder does not need to be included when pushing to git, so you can also add a .gitignore file that has `target/` specified.

Now, create a repo in GitHub and push this project to that repo. Open up your Jenkins instance and create a new Job. The job type will be a pipeline job. Call it "Maven build", and you will be automatically sent to the pipeline configuration page. Here you will see multiple options, but you can ignore all of that since everything can be defined in the Jenkinsfile. What you do need to specify is what Jenkinsfile you will be using in the build, and for that, go to the pipeline section. Here, select "Pipeline script for SCM" and "Git" as the SCM type. You then need to provide your repository details as well as the credentials. Follow [this guide](https://www.geeksforgeeks.org/how-to-add-git-credentials-in-jenkins/) if you face any issues setting up credentials.

You can then run the build and have the project get built. The unit tests you find as part of the project will be tested as well. 