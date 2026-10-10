-- 무한 도전 랭킹의 화면 모드(모바일 / PC) 구분에 쓰는 칸. Supabase → SQL Editor에 붙여 넣고 Run (한 번만)
-- 실행 전에도 게임은 그대로 동작한다(통합 랭킹만 보이고 모바일·PC 탭은 비어 있음). 실행 뒤 각자 무한 도전 기록을 세우면 채워진다.
-- ev: 최고 기록의 화면 모드('' = 모드가 생기기 전 기록), edm/esm/etm/ewm: 모바일 최고(층, 점수, 초, 검), edp/esp/etp/ewp: PC 최고
alter table public.scores add column if not exists ev text not null default '' check (ev in ('', 'm', 'p'));
alter table public.scores add column if not exists edm int not null default 0;
alter table public.scores add column if not exists esm bigint not null default 0;
alter table public.scores add column if not exists etm int not null default 0;
alter table public.scores add column if not exists ewm text not null default '' check (char_length(ewm) <= 24);
alter table public.scores add column if not exists edp int not null default 0;
alter table public.scores add column if not exists esp bigint not null default 0;
alter table public.scores add column if not exists etp int not null default 0;
alter table public.scores add column if not exists ewp text not null default '' check (char_length(ewp) <= 24);
create index if not exists scores_room_edm on public.scores (room, edm desc);
create index if not exists scores_room_edp on public.scores (room, edp desc);
notify pgrst, 'reload schema';
