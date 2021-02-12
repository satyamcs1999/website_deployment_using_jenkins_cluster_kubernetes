FROM centos

RUN yum install curl -y

RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"

RUN chmod +x kubectl

RUN mv kubectl /usr/bin

RUN mkdir /main/

RUN mkdir /root/web/

RUN mkdir /root/.kube/

COPY  ca.crt   /root/

COPY  client.crt  /root/

COPY  client.key  /root/

COPY .kube/  /root/.kube/

RUN kubectl config get-contexts

RUN yum install git -y

RUN yum install openssh-server java -y

RUN yum install java-1.8.0-openjdk -y

COPY docker.repo  /etc/yum.repos.d/

RUN yum install docker-ce --nobest -y

CMD killall firewalld -DFOREGROUND

CMD /usr/sbin/sshd -DFOREGROUND

CMD /usr/bin/dockerd -DFOREGROUND 

RUN ssh-keygen -A

EXPOSE 22

EXPOSE 8080

