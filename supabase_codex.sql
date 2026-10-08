-- 강화 랭킹에 도감 완성도(찾은 무기 수)를 싣는 칸. Supabase → SQL Editor에 붙여 넣고 Run (한 번만)
-- 실행 전에도 게임은 그대로 동작한다(도감 칸 없이 저장). 실행한 뒤부터 각자 게임을 열면 도감 수가 올라간다.
alter table public.scores add column if not exists cx int not null default 0 check (cx between 0 and 1000);
