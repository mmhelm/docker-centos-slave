# The MIT License
#
#  Copyright (c) 2017, Markus Helm
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

FROM centos:7.3.1611
MAINTAINER Markus Helm <markus.m.helm@live.de>

RUN \
	yum -y install \
		wget \
		sudo \
	&& \
	wget \
		--no-cookies \
		--no-check-certificate \
		--header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
		"http://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.rpm" \
	&& \
	yum -y install \
		jdk-*-linux-x64.rpm \
	&& \
	rm -rf jdk-*-linux-x64.rpm \
	&& \
	yum -y remove \
		wget \
	&& \
	yum clean all \
	&& \
	yum-config-manager --disable *

# Define location of the Oracle JDK
ENV JAVA_HOME /usr/java/default
# Define location of the Oracle JRE
ENV JRE_HOME /usr/java/default/jre

# Download the Jenkins Slave JAR
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/3.9/remoting-3.9.jar \
	&& chmod 755 /usr/share/jenkins \
	&& chmod 644 /usr/share/jenkins/slave.jar

# Download the Jenkins Slave StartUp Script
RUN curl --create-dirs -sSLo /usr/local/bin/jenkins-slave https://raw.githubusercontent.com/jenkinsci/docker-jnlp-slave/3.27-1/jenkins-slave \
	&& chmod a+x /usr/local/bin/jenkins-slave

# Add a dedicated jenkins system user
RUN useradd --system --shell /bin/bash --create-home --home /home/jenkins jenkins

#
# This is actually a very dirty hack because it grants sudo privilieges to user `jenkins` without password!
#
# Unfortunately the CentOS installation needs some further adaptions to project specific needs which
# cannot (or shoudn't) be done on the public internet (e.g. modify /etc/hosts, add certificates to java keystore, ...).
#
# If there's a better way to customize the installation during runtime with root access, you're welcome to improve
# this Dockerfile or to describe the approach.
#
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/jenkins

# Switch to user `jenkins`
USER jenkins

# Prepare the workspace for user `jenkins`
RUN mkdir -p /home/jenkins/.jenkins
VOLUME /home/jenkins/.jenkins
WORKDIR /home/jenkins

ENTRYPOINT ["jenkins-slave"]
