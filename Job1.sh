cp -rf * /main

shopt -s nullglob
file=(/main/*.html)


mv -f /main/dfile_web  /root/web/

if [ -f /root/web/dfile_web ]
then
  mv -f /root/web/dfile_web  /root/web/Dockerfile
else
  echo "Already Done"
fi

if ((${#file[@]}))
then
  mv -f "$file" /root/web
  docker build -t httpd_image:v1  /root/web/
  docker login -u satyams1999  -p <password>
  docker tag httpd_image:v1  satyams1999/httpd_image:v1
  docker push satyams1999/httpd_image:v1
  docker rmi -f satyams1999/httpd_image:v1
  docker rmi -f httpd_image:v1
fi  
