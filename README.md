# 검 강화하기

망치 한 번에 운명이 갈린다. 검을 강화하고 사냥터와 무한 도전에서 겨루는 픽셀 게임.

- 게임: `index.html` 하나 (글꼴·그림·음악 모두 코드 안에 들어 있음)
- 랭킹: Supabase (`supabase_setup.sql`). 학생은 로그인 없이 기기마다 익명 계정으로 자기 기록만 올린다. 랭킹 화면의 「반 코드」가 같은 사람끼리 겨룬다.
- 만든이: 바이브코딩부 교사 × Claude · 원작 플래시 「검 강화하기」 · 글꼴 갈무리(SIL OFL 1.1)

무기 계통을 추가할 때는 [계통 추가 안내](docs/WEAPON_EXTENSION.md)를 따른다. 계통 연결은 `WL`, 실제 수치·능력은 `CLASS_RULES`에서 관리하고 도감·선택지는 등록된 계통을 따라 구성된다. 현재 직업과 무기 수, 밸런스는 그대로다.


## Supabase 설치·업데이트

SQL은 운영자가 Supabase SQL Editor에서 순서대로 직접 실행한다. 게임 파일을 교체하는 것만으로 SQL이 적용되지는 않는다.

1. `supabase_setup.sql`: 계정 최고 기록 표와 소유자·공식 사이트 쓰기 정책.
2. `supabase_swords.sql`, `supabase_party.sql`: 검 이력·인원별 파티 기록 표.
3. `supabase_info.sql`, `supabase_codex.sql`: 툴팁·도감 칼럼. 앞의 표가 모두 있어야 한다.
4. `supabase_origin.sql`: 허용할 공식 사이트 주소와 계정 최고 기록 정책 최종 확인.

기존 설치에 이 수정본을 반영할 때도 `supabase_setup.sql`을 다시 실행하면 계정 최고 쓰기에 공식 사이트 조건을 유지한다. 기존 `from_official_site()` 함수가 있으면 setup은 그 함수의 허용 주소를 보존한다. 다만 swords·party·origin SQL은 그 함수를 재정의하므로 주소를 바꿔 운영한다면 세 파일의 주소를 맞춘 뒤 적용한다. `CREATE TABLE IF NOT EXISTS`는 기존 표의 임의 구조 차이까지 수정하지 않는다.

공식 사이트 확인은 Origin 헤더를 사용하는 보조 제한이다. 점수·전투의 서버 검증이나 비공개 방 접근 권한을 제공하지 않는다. 배포 서버의 정책과 실제 업로드는 운영 환경에서 별도로 확인해야 한다.
