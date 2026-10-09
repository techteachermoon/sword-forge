-- 랭킹 툴팁(검에 마우스를 올리면 계열·속성 각인·인챈트 표시)에 쓰는 칸. Supabase → SQL Editor에 붙여 넣고 Run (한 번만)
-- 실행 전에도 게임은 그대로 동작한다(툴팁에 계열만 나오고 각인·인챈트는 '기록 없음'). 실행 뒤 각자 게임을 열면 채워진다.
alter table public.swords add column if not exists info text not null default '' check (char_length(info) <= 400);
alter table public.scores add column if not exists info text not null default '' check (char_length(info) <= 801);
