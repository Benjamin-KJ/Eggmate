-- Egg Mates: apply in Supabase SQL editor or with `supabase db push`.
create extension if not exists pgcrypto;

create table public.profiles (
  id uuid primary key,
  username text not null unique check (username ~ '^[A-Za-z0-9_]{3,32}$'),
  full_name text not null check (char_length(full_name) between 1 and 80),
  bio text not null check (char_length(bio) between 1 and 240),
  avatar_url text,
  created_at timestamptz not null default now()
);
create table public.codes (
  code text primary key check (code = upper(code) and char_length(code) between 1 and 64),
  user_id1 uuid not null references public.profiles(id) on delete restrict,
  user_id2 uuid references public.profiles(id) on delete restrict,
  status text not null default 'waiting' check (status in ('waiting','matched')),
  chat_id uuid unique,
  created_at timestamptz not null default now(),
  check ((status = 'waiting' and user_id2 is null and chat_id is null) or (status = 'matched' and user_id2 is not null and chat_id is not null))
);
create table public.chats (id uuid primary key default gen_random_uuid(), code text unique not null references public.codes(code), created_at timestamptz not null default now());
create table public.messages (id uuid primary key default gen_random_uuid(), chat_id uuid not null references public.chats(id) on delete cascade, sender_id uuid not null references public.profiles(id) on delete cascade, body text not null check (char_length(trim(body)) between 1 and 2000), created_at timestamptz not null default now());
create index messages_chat_created_idx on public.messages(chat_id, created_at);

alter table public.profiles enable row level security; alter table public.codes enable row level security; alter table public.chats enable row level security; alter table public.messages enable row level security;
create policy "public profiles are readable" on public.profiles for select to anon, authenticated using (true);
create policy "public profiles can be created" on public.profiles for insert to anon, authenticated with check (true);
create policy "public profiles can be updated" on public.profiles for update to anon, authenticated using (true) with check (true);
create policy "public code reads" on public.codes for select to anon, authenticated using (true);
create policy "public chat reads" on public.chats for select to anon, authenticated using (true);
create policy "public message reads" on public.messages for select to anon, authenticated using (true);
create policy "public messages can be sent" on public.messages for insert to anon, authenticated with check (true);

-- Serializes competing claims with the code row lock; only this function may create/match codes.
create or replace function public.claim_secret_code(entered_code text, claimant_id uuid) returns table(result text, chat_id uuid, other_user_id uuid) language plpgsql security definer set search_path=public as $$
declare c public.codes; new_chat uuid; normalized text := upper(trim(entered_code));
begin
 if normalized !~ '^[A-Z0-9_-]{1,64}$' then raise exception 'Enter a valid secret code.'; end if;
 if not exists (select 1 from public.profiles where id=claimant_id) then raise exception 'Choose a profile first.'; end if;
 select * into c from public.codes where code=normalized for update;
 if not found then insert into public.codes(code,user_id1) values(normalized,claimant_id); return query select 'waiting'::text,null::uuid,null::uuid; return; end if;
 if c.status='matched' then return query select 'redeemed'::text,null::uuid,null::uuid; return; end if;
 if c.user_id1=claimant_id then return query select 'own_code'::text,null::uuid,null::uuid; return; end if;
 insert into public.chats(code) values(normalized) returning id into new_chat;
 update public.codes set user_id2=claimant_id,status='matched',chat_id=new_chat where code=normalized;
 return query select 'matched'::text,new_chat,c.user_id1;
end; $$;
revoke all on function public.claim_secret_code(text,uuid) from public; grant execute on function public.claim_secret_code(text,uuid) to anon, authenticated;

-- Storage: create the public avatar bucket in the dashboard, then apply these policies.
create policy "avatars are public" on storage.objects for select using (bucket_id='avatars');
create policy "public avatar uploads" on storage.objects for insert to anon, authenticated with check (bucket_id='avatars');
create policy "public avatar updates" on storage.objects for update to anon, authenticated using (bucket_id='avatars') with check (bucket_id='avatars');

alter publication supabase_realtime add table public.codes, public.messages;
