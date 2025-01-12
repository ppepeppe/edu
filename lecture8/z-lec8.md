# lecture-8 : CI/CD 파이프 라인
- Master Node에서 실행

```bash

# cd ~
# git clone https://github.com/yeongdeokcho/edu.git
cd  ~/kubernetes/lecture8
```


# 1. CI/CD
- git : github
- image Registry: docker-hub
- build :  docker build
- deploy: argocd
- github/docker-hub 계정 필요


# 2. Docker Build

```dtd
FROM openjdk:17-jdk-slim

# Install required tools
RUN apt-get update && apt-get install -y \
    telnet \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the JAR file into the container
COPY build/libs/*.jar demo.jar

# Expose the port Spring Boot runs on
EXPOSE 8080

# Run the Spring Boot application
CMD ["java", "-jar", "demo.jar"]
```
```bash

# docker desktop 실행

cd /Users/doong2s/src/ktds/demo
sudo docker build -f Dockerfile .  --tag k8s-edu --no-cache
# docker image 조회
docker images
docker login
docker tag k8s-edu ydcho0902/k8s-edu:v0.0.1
docker push ydcho0902/k8s-edu:v0.0.1

```
- docker buile
![docker build](/lecture8/img/lecture8-docker-build.png)
- docker hub push image 조회 
![docker hub](/lecture8/img/lecture8-docker-push.png)

# 3. k8s에 docker hub secret 생성
- dockerconfig.json : auth 값 수정
```json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "bW9zeUBwYXQhbJ5jb206ZnJvYXNzd29yZA=="
    }
  }
}
```
```bash

# 로컬 PC에서 실행 : docker login 후
# Docker 로그인 정보를 Base64로 인코딩
#echo -n 'my-docker-username:my-docker-password' | base64

echo -n 'mosy@paran.com:f..&..' | base64
bW9zeUBwYXQhbJ5jb206ZnJvYXNzd29yZA==

# auth 값 수정
vi dockerconfig.json 

cat dockerconfig.json | base64
ewogICJhdXRocyI6IHsKICAgICJodHRwczovL2luZGV4LmRv...생략...==
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: k8s-edu-dockerhub-secret
  namespace: default
data:
  .dockerconfigjson: >
    eyJhdXRocyI6eyJodHRwczovL2luZGV4LmRvY2tlci5pby92MSguZG9ja...생략...==
type: kubernetes.io/dockerconfigjson
```
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: k8s-edu-deployment
spec:
  selector:
    matchLabels:
      app: k8s-edu-app
  replicas: 1
  template:
    metadata:
      labels:
        app: k8s-edu-app
        version: blue
    spec:
      containers:
        - name: k8s-edu-app
          image: ydcho0902/k8s-edu:v0.0.1      # dockerhub image repository : repo/image명:Tag 
          imagePullPolicy: IfNotPresent        # k8s 클러스터에 다운로드 된 이미지 없으면 다운 or Always 
          ports:
            - name: http
              containerPort: 8080              # demo.jar 실행 포트
              protocol: TCP
          resources:                           # pod 사용 리소스 설정 블록
            requests:                          # 생성시 필요한 최소 리소스 
              cpu: "1"
              memory: "2Gi"
            limits:                            # pod가 사용 가능한 최대 리소스 
              cpu: "1"
              memory: "2Gi"
          env:                                 # pod 내 환경 변수 설정
            - name: SPRING_PROFILES_ACTIVE     # spring profile 설정 
              value: prod                      # 상용(prod) 환경 
      imagePullSecrets:                        # dockerhub 이미지 pull 위한 secret 
        - name: k8s-edu-dockerhub-secret
      nodeSelector:                            # pod가 실행 될 node 설정 
        kubernetes.io/hostname: worker01

---
apiVersion: v1
kind: Service
metadata:
  name: k8s-edu-service
spec:
  selector:
    app: k8s-edu-app
    version: blue  # 기본적으로 Blue 배포에 연결
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080                        # deployment에서 설정한 컨테이너 포트 매핑

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: k8s-edu-ingress
spec:
  ingressClassName: nginx
  rules:
    - host: "k8s.211.253.25.128.sslip.io"
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: k8s-edu-service
                port:
                  number: 80
```

```bash

# Master01 노드에서 진행
kubectl apply -f docker-secret.yaml
kubectl get secret

kubectl apply -f demo-deploy.yaml

# 브라우저에서 확인
http://k8s.211.253.25.128.sslip.io/api/v1/user/82265604

```