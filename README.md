__<h1>Website deployment using Jenkins Cluster and Kubernetes</h1>__

![Jenkins_Docker_Kubernetes](https://miro.medium.com/max/875/1*ATtQsHTpHrY3P6efklQ9KA.png)<br>

<h2> Content </h2>
<h4><ul>
<li><i>Configuration of Docker Host and Client</i></li>
<li><i>Creation of Dockerfile for creation of Image to be used as an agent</i></li> 
<li><i>Configuration of Dynamic Cloud with Docker Agent in Jenkins</i></li> 
<li><i>Creation of Jenkins Slave Node Jobs</i></li>
</ul></h4><br>

<h2> Prerequisites for the following setup includes: </h2>
<h4><ul>
<li><i>Setup of RHEL8 VM (in case base OS is Windows or MacOS)</i></li>
<li><i>Setup of Docker, Jenkins and kubectl within the respective VM</i></li> 
<li><i>Minikube as well as kubectl needs to be installed in base OS</i></li> 
</ul></h4><br>

<h2> Configuration of Docker Host and Client </h2>

Consider two systems, one as Docker Host and the other as Docker Client, and understand the configuration required in both of them for implementing the following setup

<h3> Docker Host: </h3>
<ul>
  <li>To configure the Docker Host, the first thing that needs to be configured is <b>/usr/lib/systemd/system/docker.service</b>, this path could be obtained by the output of <b>systemctl status docker</b>.</li><br>
  
  ![systemctl_status_docker](https://miro.medium.com/max/875/1*hDITYJiEZeEFxjJIDlEw8g.png)<br>
  
  <p align="center"><b>“systemctl status docker” command output</b></p><br>
  
  <li>After accessing the docker.service file , the <b>ExecStart</b> keyword within it is modified as per requirement i.e., <b>-H tcp:0.0.0.0:4243</b>. This modification allows TCP communication from any IP on the port 4243. Port 4243 is also one of the Docker port used.</li><br>
  
  ![modified_docker.service_file](https://miro.medium.com/max/875/1*UvKpudOvKrwSgGXURavCtA.png)<br>
  
  <p align="center"><b>Modified docker.service file</b></p><br>
  
  <li>After the file is modified , it needs to be reloaded to implement the changes , and therefore the command below is used for the same</li><br>
  
  ```
  systemctl daemon-reload
  ```
  
  <br>
  <li>Next, the docker service needs to be restarted as well, the command used for the same is</li><br>
  
  ```
  systemctl restart docker
  ```
  
</ul><br>

<h3> Docker Client: </h3>
<ul>
  <li>After the required setup in the Docker Host, Docker service, if running , needs to be stopped in this system, and could be done by following command:</li><br>
  
  ```
  systemctl stop docker
  ```
  
  <br>
  <li>Next, the IP of the Docker Host needs to be exported from this system using the <b>DOCKER_HOST</b> variable and export command is used for the same.</li><br>
  
  ```
  export DOCKER_HOST=<DOCKER_HOST_IP>:4243
  ```
  
</ul><br>

<h2> Creation of Dockerfile for creation of Image to be used as an agent </h2>

<ul>
  <li>First of all , a Dockerfile is created for generation of image to be used as a Docker agent for Dynamic Jenkins Slave.</li><br>
  
  ```
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
  ```
  
  <li>Next, image could be build using the following command, also it is necessary to name the dockerfile as <b>‘Dockerfile’</b> for the command to execute successfully.</li><br>
  
  ```
  docker build -t image_name:version  /path/to/Dockerfile
  ```
  
  <br>
  <li>Also , the image generated needs to be pushed to public Docker registry like <b>Docker Hub</b>. So before executing the commands below , it is necessary to have an account in Docker Hub, the link for the same is present at the bottom of this README.</li><br>
  
  ```
  docker login -u <Docker Hub username>  -p <Docker Hub password>
  ```
  
  <br>
  <li>After login to Docker Hub using the CLI, tag operation needs to be performed before pushing the image , the reason being that the image name format should be <b><Docker Hub username>/image_name:version</b>, the command for the same is as follows:</li><br>
  
  ```
  docker tag image_name:version  <Docker Hub username>/image_name:version
  ```
  
  <br>
  <li>After tagging, the image could be pushed using the command below:</li><br>
  
  ```
  docker push <Docker Hub username>/image_name:version
  ```
  
</ul><br>

<h2> Configuration of Dynamic Cloud with Docker Agent in Jenkins </h2>

<ul>
  <li>Cloud is the one that would launch the Dynamic Jenkins Slave, Jenkins is accessed from the system acting as the Docker Client.</li><br>
  <li>Before starting the configuration of Dynamic Cloud in Jenkins, <b>Docker</b> plugin should be installed and could be installed from <b>Manage Plugins</b> in the <b>Manage Jenkins</b> section.</li><br>
  
  ![Docker_plugin](https://miro.medium.com/max/875/1*tYLpl6Q8Fcy84gfaWp5YlA.png)<br>
  
  <p align="center"><b>Docker Plugin</b></p><br>
  <li>Clouds in Jenkins could be configured by accessing <b>Manage Jenkins</b> > <b>Manage Nodes and Clouds</b> > <b>Configure Clouds</b>.</li><br>
  
  ![Setting_up_Docker_Host](https://miro.medium.com/max/875/1*rhjbC-mczHM8rZmCsioPsA.png)<br>
  
  <p align="center"><b>Setting up Docker Host (Docker Client IP is mentioned above )</b></p><br>
  
  ![Docker(Slave)_Agent_Setup](https://miro.medium.com/max/875/1*JTffPm79V9bBsWgoSv5P1A.png)<br>
  
  <p align="center"><b>Docker(Slave) Agent Setup (The image specified is generated from the Dockerfile mentioned above)</b></p><br>
  
  ![Connect_Method](https://miro.medium.com/max/875/1*4nkKGAXmbVMeYbh2uPVL9w.png)<br>
  
  <p align="center"><b>Connect Method is SSH between Master and Slave, also the prerequisites mentioned needs to be satisfied by the Docker Image mentioned , other than this , SSH Key needs to generated and this requirements are satisfied and could be observed in the Dockerfile above.</b></p><br>
  
  ![Image_Pull_Strategy](https://miro.medium.com/max/875/1*MfBUP7_J6p34fMpVXuCBXA.png)<br>
  
  <p align="center"><b>Image Pull Strategy every time Jenkins Slave is created</b></p><br>
  
</ul><br>

<h2> Creation of Jenkins Slave Node Jobs </h2>
<p>Some setup that are common for both jobs, is as follows:</p>
<ul>
  <li>For both the job to run under the slave created dynamically, it should be restricted by placing the label that was mentioned during the configuration of dynamic cloud.</li><br>
  
  ![kube_slave](https://miro.medium.com/max/875/1*WgUKwT0dMreMO5sAaIo1yQ.png)<br>
  
  <p align="center"><b>Here, kube-slave is the label used</b></p><br>
  <li>Next setup involves setting up GitHub hook triggers , and could be added using a webhook to the GitHub repo. For creation of webhook in the repo, public URL is required that could be generated using <b>ngrok</b>, using the concept of <b>Tunneling</b>.</li><br>
  
  ```
  ./ngrok http 8080
  ```
  
  ![public_url_ngrok](https://miro.medium.com/max/875/1*lHHWjpUEkiMzOku_Xo_amQ.png)<br>
  
  <p align="center"><b>Public URL using ngrok</b></p><br>
  
  ![webhook_addition](https://miro.medium.com/max/875/1*bX67d4-VfI74yllkjECLLg.png)<br>
  
  <p align="center"><b>Addition of Webhook to the GitHub repository</b></p><br>
  
</ul><br>

<h3> Job 1 </h3>

<ul>
  <li>In this job ,certain program files needs to be obtained from SCM(Source Code Management) like <b>GitHub</b> in this case. Thereby GitHub repo URL needs to be specified in the Job itself.</li><br>
  
  ![github_repo_branch_specified](https://miro.medium.com/max/875/1*1-71RFSmRkmyymdVdnrIvw.png)<br>
  
  <p align="center"><b>Specification of GitHub repo and branch</b></p><br>
  
  ![build_trigger_job1](https://miro.medium.com/max/554/1*ph4l9mVd4F3ZCad53eM9Ew.png)<br>
  
  <p align="center"><b>Build Trigger for Job 1</b></p><br>
  <li>The script used for implementation of Job 1 is as follows :</li><br>
  
  ![job1_script](https://miro.medium.com/max/875/1*pdH3Xkl5btOhtHrnEZDASg.png)<br>
  
  <p align="center"><b>Job 1 Shell Script</b></p><br>
  <li>The above script needs a Dockerfile(dfile_web) , which is shown below</li><br>
  
  ```
  FROM centos 
  RUN yum install httpd -y 
  COPY *.html  /var/www/html/ 
  CMD /usr/sbin/httpd -DFOREGROUND 
  EXPOSE 80/tcp
  ```
  
  <br>
  <li>The script builds the image for the Apache HTTPD Webserver using the Dockerfile above and tags to the format needed to push the image to DockerHub , and then it logins to DockerHub and pushes the tagged image.</li><br>
  <li>The local copy of image and the tagged image is removed to avoid conflict in case it gets triggered again due to changes in SCM.</li><br>
</ul><br>

<h3> Job 2 </h3>

<ul>
  <li>This job is the <b>downstream</b> project for Job 1, the YAML file to set up Kubernetes deployment needs to be obtained from SCM, i.e., GitHub in this case. Here , the file is specified in different branch i.e., modify of the repository same as the one used by Job 1, the reason being to avoid copying unnecessary file.</li><br>
  
  ![github_repo_branch_specified_job2](https://miro.medium.com/max/875/1*krcYBNwLuKipfNyQYBtF1g.png)<br>
  
  <p align="center"><b>Specification of GitHub repo and branch</b></p><br>
  
  ![build_trigger_job2](https://miro.medium.com/max/875/1*merUCfmODUnNOTD-DBjhzA.png)<br>
  
  <p align="center"><b>Build Trigger for Job 2</b></p><br>
  <li>The script used for implementation of Job 2 is as follows:</li><br>
  
  ![job2_script](https://miro.medium.com/max/875/1*qZUksm76Sup7z5qC6gGZsg.png)<br>
  
  <p align="center"><b>Job 2 Shell Script</b></p><br>
  <li>The YAML file(kub_task4.yaml) required in the above file is shown below</li><br>
  
  ```
  apiVersion: apps/v1
  kind: Deployment
  metadata:  
    name: task4-deploy  
    labels:    
      app: kubapp
  spec:  
    replicas: 1  
    selector:    
      matchLabels:      
        app: kubapp  
    template:    
      metadata:      
        labels:        
          app: kubapp    
      spec:      
        containers:       
         - name: task4-httpd          
           image: satyams1999/httpd_image:v1          
           imagePullPolicy: "Always"      
        nodeSelector:        
          kubernetes.io/hostname: minikube
  ```
  
  <br>
  <li>The Job 2 script creates a Kubernetes deployment using the above script and if deployment already exists , it performs <b>rollout</b> operations which updates the existing pod in the deployment(useful in cases where image is modified and needs to be implemented with zero downtime).</li><br>
  <li>Else, if deployment doesn’t exists already, it creates the deployment and expose it as well.</li><br>
</ul>

<h3> Output </h3>

![output](https://miro.medium.com/max/875/1*En-VConMijzkqB8L9768_Q.png)<br>

<h2>Thank You :smiley:<h2>
<h3>Docker Hub Link</h3>
https://hub.docker.com/
<br>

<h3>LinkedIn Profile</h3>
https://www.linkedin.com/in/satyam-singh-95a266182

