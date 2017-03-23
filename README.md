# Jenkins JNLP Agent Docker Image based on CentOS 7

[![Docker Stars](https://img.shields.io/docker/stars/mhelm/docker-centos-slave.svg)](https://hub.docker.com/r/mhelm/docker-centos-slave/)
[![Docker Pulls](https://img.shields.io/docker/pulls/mhelm/docker-centos-slave.svg)](https://hub.docker.com/r/mhelm/docker-centos-slave/)
[![Docker Automated build](https://img.shields.io/docker/automated/mhelm/docker-centos-slave.svg)](https://hub.docker.com/r/mhelm/docker-centos-slave/)

This image is based on the [jenkinsci/docker-jnlp-slave:alpine](https://github.com/jenkinsci/docker-jnlp-slave/tree/alpine) but extends from CentOS 7 ([centos:7.3.1611](https://hub.docker.com/r/library/centos/tags/centos7.3.1611/)) instead of Alpine Linux ([openjdk:8-jdk-alpine](https://hub.docker.com/r/library/openjdk/tags/8-jdk-alpine/)).
The agent (`slave.jar`) used in this image relies on the [Jenkins Remoting library](https://github.com/jenkinsci/remoting) and is taken from the base [Jenkins Agent Docker image](https://github.com/jenkinsci/docker-slave/).

This image is ready-to-use for the [Jenkins Kubernetes Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Kubernetes+Plugin). It contains additional packages which are need to build the project's software.

See [Jenkins Distributed builds](https://wiki.jenkins-ci.org/display/JENKINS/Distributed+builds) for more information about how to use Jenkins agents.

## Docker

Run a Docker container with

    docker run mhelm/docker-centos-slave:extended -url http://jenkins-server:port <secret> <agent name>

Optional environment variables:

* `JENKINS_URL`: url for the Jenkins server, can be used as a replacement to `-url` option, or to set alternate jenkins URL
* `JENKINS_TUNNEL`: (`HOST:PORT`) connect to this agent's host and port instead of the Jenkins server directly, assuming this one routes TCP traffic to the Jenkins master
* `JENKINS_SECRET`: agent secret, if not set as an argument
* `JENKINS_AGENT_NAME`: agent name, if not set as an argument

## Kubernetes Pipeline

In the `Jenkinsfile` use this Docker image in the `containerTemplate` of the [Jenkins Kubernetes Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Kubernetes+Plugin).

*Avoid using the `container` step in the pipeline script as it makes the build unstable (see [JENKINS-40825](https://issues.jenkins-ci.org/browse/JENKINS-40825)).*

    podTemplate(label: 'kubernetes', containers: [
        containerTemplate(
          name: 'jnlp',
          image: 'mhelm/docker-centos-slave:extended',
          args: '${computer.jnlpmac} ${computer.name}',
          ttyEnabled: true,
          env: [
            containerEnvVar(key: ..., value: ...)
          ]
        )
      ]) {
      node('kubernetes') {
        ...
      }
    }
