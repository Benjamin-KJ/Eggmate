# Egg Mates

A responsive HTML, CSS, JavaScript + Supabase social match app. No framework, build tool, package installation, or Supabase Auth is required. Sign-up and sign-in are browser-only: the browser saves a hashed password and the current profile in local storage. Supabase stores the shared profiles, photos, codes, and messages. No service-role key is used in the browser.

## Run it

1. Create a Supabase project. No Authentication provider setup is needed.
2. In **Storage**, create a **public** bucket named `avatars` (file size/type limits are recommended).
3. Run [`supabase/migrations/20260911000000_egg_mates.sql`](supabase/migrations/20260911000000_egg_mates.sql) in the SQL editor. It creates tables, atomic matching RPC, RLS policies, realtime publication, and avatar storage policies.
4. Open `index.html` and replace the `URL` and `KEY` placeholders near the bottom with the Project URL and **anon/publishable** key from Supabase's API settings. Do not use a service-role key.
5. Open the folder in VS Code and launch `index.html` with the **Live Server** extension. Alternatively, open `index.html` directly in a browser; Live Server is recommended for a reliable local development experience.

## Security notes

- The browser uses only `VITE_SUPABASE_ANON_KEY`; never put `service_role` in any `VITE_` variable.
- `claim_secret_code` is a transaction-like RPC that locks the code row, preventing two simultaneous second claims.
- This is a public/demo implementation. Without Supabase Auth, RLS cannot prove a caller's identity, so public policies are required for the browser to use the shared data. Browser-only accounts work only in the browser where they were created; they are not real, cross-device accounts.
- For a production app, restore Supabase Auth and the authenticated RLS policies.
