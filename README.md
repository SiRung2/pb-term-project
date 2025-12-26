# Term Project - To-Do (Web + Mobile)

## 프로젝트 소개
WebApp(React/Vite)과 Mobile App(Flutter)이 동일한 Firebase 프로젝트를 공유하여
Google 로그인 후 To-Do 데이터를 Firestore에 저장/조회/수정/삭제(CRUD)할 수 있는 앱입니다.

- Firebase: Authentication(Google) + Firestore
- Web 배포: JCloud (Nginx)

## 기능 설명
- Google 로그인 / 로그아웃
- To-Do CRUD
    - 추가(Add)
    - 목록 조회(Read)
    - 완료 체크(Update)
    - 삭제(Delete)
- Web/Mobile이 같은 Firestore(todos 컬렉션) 데이터를 공유

## 실행 방법 (웹)
npm install
npm run dev
npm run build

## 실행 방법 (모바일)
flutter pub get
flutter run

### WebApp 실행(로컬)
```bash 
cd web
npm install
npm run dev
