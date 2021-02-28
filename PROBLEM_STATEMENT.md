__<h1>Problem Statement</h1>__

<ul>
  <li>Create container image that has Linux and other basic configuration required to run Slave for Jenkins.</li>
  <li>When we launch the job it should automatically starts job on slave based on the label provided for dynamic approach.</li>
  <li>Create a Job chain of Job1 & Job2 in Jenkins.</li> 
  <li>Job1 : Pull the GitHub repo automatically when some developers push repo to GitHub and perform the following operations as:</li>
    <ol>
      <li>Create the new image dynamically for the application and copy the application code into that corresponding Docker image. </li>
      <li>Push that image to the DockerHub (Public repository).</li>
    </ol>
    <p>( GitHub code contain the application code and Dockerfile to create a new image )</p>
  <li>Job2 ( Should be run on the dynamic slave of Jenkins configured with Kubernetes kubectl command): Launch the application on the top of Kubernetes cluster performing following operations:</li>
    <ol>
      <li>If launching first time then create a deployment of the pod using the image created in the previous job. Else if deployment already exists then do rollout of the existing pod making zero downtime  for the user.</li>
      <li>If Application created first time, then Expose the application or else don’t expose it.</li>
    </ol>
</ul>
