-- 검 강화하기 랭킹 테이블 (Supabase → SQL Editor에 붙여 넣고 Run)
create table if not exists public.scores (
  id uuid primary key default auth.uid() references auth.users on delete cascade,
  room text not null default '' check (char_length(room) <= 12),
  name text not null check (char_length(name) between 1 and 8),
  title text not null default '',
  best int not null default 0 check (best between 0 and 35),
  stage int not null default 0,
  diff text not null default 'normal',
  sv int not null default 2,
  wep text not null default 'c',
  es bigint not null default 0,
  et int not null default 0,
  ed int not null default 0,
  ew text not null default '',
  updated_at timestamptz not null default now()
);
create index if not exists scores_room_best on public.scores (room, best desc);
create index if not exists scores_room_es on public.scores (room, es desc);

-- "Automatically expose new tables"를 끈 프로젝트용: 이 표만 Data API에 열어 준다 (켜 둔 프로젝트에서도 실행해도 괜찮다)
grant usage on schema public to anon, authenticated;
grant select on public.scores to anon, authenticated;
grant insert, update on public.scores to authenticated;

alter table public.scores enable row level security;
-- 누구나 랭킹을 볼 수 있고, 자기 기기(익명 계정)의 줄만 쓰고 고칠 수 있다
drop policy if exists "scores read" on public.scores;
create policy "scores read" on public.scores for select using (true);
drop policy if exists "scores insert own" on public.scores;
create policy "scores insert own" on public.scores for insert with check (auth.uid() = id);
drop policy if exists "scores update own" on public.scores;
create policy "scores update own" on public.scores for update using (auth.uid() = id) with check (auth.uid() = id);
