# lecture-2
- Master Node에서 실행

```bash

# cd ~
# git clone https://github.com/yeongdeokcho/edu.git
cd  ~/kubernetes/lecture2
```


# Service

## 1. nginx deployment 배포
```bash

## 이전 배포 clear
kubectl delete -f deploy.yaml

## 서비스용 배포 
kubectl apply -f deploy.yaml

```
## 2. clusterIP
clusterip-svc.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP

```
```sh

# 서비스 생성
kubectl apply -f clusterip-svc.yaml

# 서비스 조회
kubectl get service
kubectl get svc

## 가상의 서비스 ip가 생성되었다 
root@master01:~/kubernetes/lecture2# kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP   9d
nginx-svc    ClusterIP   10.43.88.2   <none>        80/TCP    4s


## master01에서 다음과 같이 cluster-ip로  조회가 가능해진다 
curl http://10.43.54.221

## 서비스가 로드밸렁스 하는지 확인해 본다 (3개 에 모두 적용)
## Master Node에서 실행
## nginx 3개 pod에 index.html 파일 생성해 LB 동작하는지 확인  
### k9s에서 진행하는것을 추천
kubectl get pods
kubectl  exec -it nginx-deployment-678c6b9b69-8s247  -- bash

# 수정 전 index.html 내용 확인
cat /usr/share/nginx/html/index.html
# index.html 내용 수정
echo nginx-1 > /usr/share/nginx/html/index.html
echo nginx-2 > /usr/share/nginx/html/index.html
echo nginx-3 > /usr/share/nginx/html/index.html

## master01에서 실행해 본다 
curl http://10.43.54.221

## 또는 for-loop
for i in {1..10} 
do
  curl http://10.43.54.221
  echo " (${i})"
  sleep 1
done


# endpoints 조회
kubectl get endpoints 
kubectl get ep

kubectl describe service nginx-svc
```

## 3. nodePort
nodeport-svc.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      nodePort: 30001
      port: 80
      targetPort: 80
  type: NodePort

```
```bash

kubectl apply -f nodeport-svc.yaml

kubectl get svc
root@master01:~/kubernetes/lecture2# kubectl get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.43.0.1      <none>        443/TCP        9d
nginx-svc    NodePort    10.43.148.76   <none>        80:30001/TCP   114s
# podd의 속한  node 확인한다 
kubectl get pod -o wide
kubectl get nodes -o wide

# Master Node에서 node의 ip로 조회 해본다( cluseter 외부에서 조회 가능)
curl 172.27.0.179:30001 ## master01
curl 172.27.0.136:30001  ## worker01
curl 172.27.0.48:30001   ## worker02

# kt cloud 콘솔 접속 
# 방화벽 30001 번 오픈 (master01,worker01,worker02)
# GNB내 : Server > Networking > 공인IP 선택 > 접속설정 클릭 
  a. 포트를 범위로 설정 선택
  b. 공인 IP에 할당된 서버 선택 > start, end에 30001 입력 > TCP 선택 후 저장 
# https://cloud.kt.com/console/g/networklist#
# worker node 공인IP 로 접속, 웹 브라우저로 접속
curl http://211.253.25.128:30001  ## master01
curl http://211.253.30.100:30001 ## worker01
curl http://211.253.8.141:30001  ## worker02

kubectl delete -f nodeport-svc.yaml
```
![노드포트 방화벽 오픈](/lecture2/img/lecture2-fw.png)
![노드포트 방화벽 오픈](/lecture2/img/lecture2-fw-30001.png)

## 4. LoadBalancer
loadbalancer-svc.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
```
```sh

kubectl apply -f loadbalancer-svc.yaml
## EXTERNAL-IP pending 확인 : cluster L7 매핑 없어서.
root@master01:~/kubernetes/lecture2# kubectl get svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP      10.43.0.1       <none>        443/TCP        9d
nginx-svc    LoadBalancer   10.43.140.246   <pending>     80:30442/TCP   14s
```

## externalName
- google로 테스트

external-svc.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: externalname1
spec:
  type: ExternalName
  externalName: google.com
```
```sh

kubectl apply -f external-svc.yaml

kubectl get svc
# EXTERNAL-IP에 google.com 설정 확인
root@master01:~/kubernetes/lecture2# kubectl get svc
NAME            TYPE           CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
externalname1   ExternalName   <none>       google.com    <none>    6m12s
kubernetes      ClusterIP      10.43.0.1    <none>        443/TCP   9d


## test pod 내에서 curl 확인 
## curlimages 이미지로  mycurlpod pod 생성 완료되면  pod 안에 접속 됨 

kubectl run mycurlpod --image=curlimages/curl -i --tty -- sh
## 직접 접속도 가능
## kubectl exec -it  mycurlpod -- bash

## 구글 메인페이지 출력
curl -L externalname1.default.svc.cluster.local

```

# clear
```sh

kubectl delete -f loadbalancer-svc.yaml
kubectl delete -f deploy.yaml
kubectl delete -f external-svc.yaml
kubectl delete -f nodeport-svc.yaml
kubectl delete -fclusterip-svc.yaml

```