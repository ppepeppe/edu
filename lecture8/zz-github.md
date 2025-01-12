# lecture-8 : GitHub PAT(Personal Access Token) 생성

# 1. github 로그인
- 사이트 : https://github.com

# 2. PAT(Personal Access Token) 생성
- Settings 선택 : 우측 상단 프로필 사진 선택 후
  ![PAT 생성](/lecture8/img/lecture8-github-pat01.png)
- 좌측 LNB 메뉴 Developer setting 선택 : 맨 아래
  ![PAT 생성](/lecture8/img/lecture8-github-pat02.png)
- 좌측 LNB 메뉴 Personal access token 선택 : Tokens (classic) 선택
  ![PAT 생성](/lecture8/img/lecture8-github-pat03.png)
- 우측 선택 Generate new token 선택
  ![PAT 생성](/lecture8/img/lecture8-github-pat04.png)
- 신규 토큰 이름, 만료기간, 권한 등 설정 
  - 이름 : k8s-edu
  - 만료기간 : 90일 
  - 권한 : write:packages, delete:packages 선택
  - 토큰 생성 : "Generate token" 클릭
  ![PAT 생성](/lecture8/img/lecture8-github-pat05.png)
  ![PAT 생성](/lecture8/img/lecture8-github-pat06.png)
  
- 토큰 복사 : [주의] 생성 시 한번 확인, 페이지를 벗어나면 더이상 토큰을 확인할 수 없음. 
  ![PAT 생성](/lecture8/img/lecture8-github-pat07.png)
