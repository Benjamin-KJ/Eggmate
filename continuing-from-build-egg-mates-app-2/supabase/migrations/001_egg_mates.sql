-- Password-free prototype schema. Do not use this anonymous-owner design for sensitive data.
-- For strong ownership enforcement, use Supabase Auth and change the policies to auth.uid().
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key, username text not null unique check (username ~ '^[a-zA-Z0-9_]{3,30}$'),
  full_name text not null check (char_length(full_name) between 1 and 80),
  photo_url text, bio text not null default '' check (char_length(bio) <= 240), created_at timestamptz not null default now()
);
create table if not exists public.codes (
  code text primary key check (code ~ '^[A-Z0-9-]{3,40}$'), user_id_1 uuid references public.profiles(id) on delete set null,
  user_id_2 uuid references public.profiles(id) on delete set null, chat_id uuid unique, status text not null default 'waiting' check(status in ('waiting','matched')), created_at timestamptz not null default now()
);
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(), chat_id uuid not null references public.codes(chat_id) on delete cascade,
  sender_id uuid references public.profiles(id) on delete set null, body text not null check(char_length(body) between 1 and 1000), created_at timestamptz not null default now()
);

create or replace function public.claim_code(p_code text, p_user_id uuid)
returns public.codes language plpgsql security definer set search_path=public as $$
declare result public.codes;
begin
  insert into codes(code,user_id_1,status) values (upper(trim(p_code)),p_user_id,'waiting') on conflict (code) do nothing;
  select * into result from codes where code=upper(trim(p_code)) for update;
  if result.user_id_1=p_user_id or result.user_id_2=p_user_id then return result; end if;
  if result.status='matched' then raise exception 'This code has already been redeemed by two Egg Mates!'; end if;
  update codes set user_id_2=p_user_id,status='matched',chat_id=gen_random_uuid() where code=result.code returning * into result;
  return result;
end $$;

alter table profiles enable row level security; alter table codes enable row level security; alter table messages enable row level security;
-- Required for a no-auth prototype. These policies intentionally allow public data access.
create policy "public profiles" on profiles for all to anon using (true) with check (true);
create policy "public codes" on codes for select to anon using (true);
create policy "public messages" on messages for all to anon using (true) with check (true);
grant execute on function public.claim_code(text,uuid) to anon;
alter publication supabase_realtime add table public.messages, public.codes;
