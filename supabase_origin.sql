-- 공식 사이트(https://swordforge.pages.dev, https://techteachermoon.github.io)에서 보낸 기록만 랭킹에 쓰도록 막는다.
-- 게임을 통째로 복사해 간 다른 사이트가 이 저장소에 기록을 넣는 것을 대부분 걸러 낸다.
-- (브라우저가 붙이는 Origin 헤더를 보는 방식이라, 마음먹고 조작하는 사람까지 완벽히 막지는 못한다)
-- Supabase → SQL Editor에 붙여 넣고 Run. 사이트 주소가 바뀌면 아래 주소를 고쳐서 다시 Run.

create or replace function public.from_official_site() returns boolean
language sql stable as $$
  select coalesce(current_setting('request.headers', true)::json->>'origin', '') in (
    'https://swordforge.pages.dev',
    'https://techteachermoon.github.io'
  )
  -- Cloudflare 미리보기 주소(abc123.swordforge.pages.dev)도 허용
  or coalesce(current_setting('request.headers', true)::json->>'origin', '') like 'https://%.swordforge.pages.dev'
$$;

drop policy if exists "scores insert own" on public.scores;
create policy "scores insert own" on public.scores for insert
  with check (auth.uid() = id and public.from_official_site());

drop policy if exists "scores update own" on public.scores;
create policy "scores update own" on public.scores for update
  using (auth.uid() = id)
  with check (auth.uid() = id and public.from_official_site());
