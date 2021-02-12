cp -rf * /root

shopt -s nullglob
file=(/root/*/yaml)

if kubectl get deployment | grep task4-deploy
then
  kubectl rollout restart deployment/task4-deploy
else
  kubectl create -f "$file"
  kubectl expose deployment task4-deploy --port=81  --type=NodePort   --target-port=80
fi

kubectl get service 