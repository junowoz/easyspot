-- Create a table for public profiles
create table profiles (
  id uuid references auth.users on delete cascade not null primary key,
  updated_at timestamp with time zone,
  username text unique,
  full_name text,
  email text,
  avatar_url text,
  website text,

  constraint username_length check (char_length(username) >= 1)
);
-- Set up Row Level Security (RLS)
-- See https://supabase.com/docs/guides/auth/row-level-security for more details.
alter table profiles
  enable row level security;

create policy "Profiles are viewable by users who created them." on profiles 
  for select using ( auth.uid() = id );

create policy "Users can insert their own profile." on profiles
  for insert with check (auth.uid() = id);

create policy "Users can update own profile." on profiles
  for update using (auth.uid() = id);

-- This trigger automatically creates a profile entry when a new user signs up via Supabase Auth.
-- See https://supabase.com/docs/guides/auth/managing-user-data#using-triggers for more details.
create or replace function public.handle_new_user_with_resume()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_url, email, username)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->'user_metadata'->>'email', new.raw_user_meta_data->'user_metadata'->>'user_name');
  insert into public.resumes (profile_id, theme, content)
  values (new.id, 'default', '{}');
  return new;
end;
$$ language plpgsql security definer;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user_with_resume();

-- Set up Storage!
insert into storage.buckets (id, name)
  values ('avatars', 'avatars');

-- Set up access controls for storage.
-- See https://supabase.com/docs/guides/storage#policy-examples for more details.
create policy "Avatar images are publicly accessible." on storage.objects
  for select using (bucket_id = 'avatars');

create policy "Anyone can upload an avatar." on storage.objects
  for insert with check (bucket_id = 'avatars');














CREATE TABLE public.resumes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  theme VARCHAR NOT NULL,
  content JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.resumes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own resumes." ON public.resumes 
FOR SELECT USING (auth.uid() = profile_id);

CREATE POLICY "Users can update own resumes." ON public.resumes
FOR UPDATE USING (auth.uid() = profile_id);

CREATE POLICY "Users can delete own resumes." ON public.resumes
FOR DELETE USING (auth.uid() = profile_id);

CREATE POLICY "Users can insert resumes." ON public.resumes
FOR INSERT WITH CHECK (auth.uid() = profile_id);



------------------------------

user metadata for linkedin

{
  id: 'ebc9bb0b-5136-4669-8b3b-d94d5f70b17e',
  aud: 'authenticated',
  role: 'authenticated',
  email: 'junogouvea@gmail.com',
  email_confirmed_at: '2023-08-02T18:58:13.377883Z',
  phone: '',
  confirmed_at: '2023-08-02T18:58:13.377883Z',
  last_sign_in_at: '2023-08-02T18:58:17.300186Z',
  app_metadata: { provider: 'linkedin', providers: [ 'linkedin' ] },
  user_metadata: {
    avatar_url: 'https://media.licdn.com/dms/image/D4D03AQHxd9DuOciHDg/profile-displayphoto-shrink_100_100/0/1684439238428?e=1696464000&v=beta&t=8WR3c4DZyzFbz2Zmh_EexU8MiGKecVE1axCyabTq_hQ',
    email: 'junogouvea@gmail.com',
    email_verified: true,
    full_name: 'Juan José Gouvêa',
    iss: 'https://api.linkedin.com',
    name: 'Juan José Gouvêa',
    picture: 'https://media.licdn.com/dms/image/D4D03AQHxd9DuOciHDg/profile-displayphoto-shrink_100_100/0/1684439238428?e=1696464000&v=beta&t=8WR3c4DZyzFbz2Zmh_EexU8MiGKecVE1axCyabTq_hQ',
    provider_id: 'hjrQb2hLk7',
    sub: 'hjrQb2hLk7'
  },
  identities: [
    {
      id: 'hjrQb2hLk7',
      user_id: 'ebc9bb0b-5136-4669-8b3b-d94d5f70b17e',
      identity_data: [Object],
      provider: 'linkedin',
      last_sign_in_at: '2023-08-02T18:58:13.373866Z',
      created_at: '2023-08-02T18:58:13.373911Z',
      updated_at: '2023-08-02T18:58:13.373911Z'
    }
  ],
  created_at: '2023-08-02T18:58:13.36759Z',
  updated_at: '2023-08-02T18:58:17.312958Z'
}


-----------------------------------------

linkedin:

{
  "id": "f6c6bea9-3804-4dac-b012-7e56ca0d81b5",
  "aud": "authenticated",
  "role": "authenticated",
  "email": "junogouvea@gmail.com",
  "email_confirmed_at": "2023-08-03T02:51:34.186148Z",
  "phone": "",
  "confirmed_at": "2023-08-03T02:51:34.186148Z",
  "last_sign_in_at": "2023-08-03T02:51:38.093407Z",
  "app_metadata": {
    "provider": "linkedin",
    "providers": [
      "linkedin"
    ]
  },
  "user_metadata": {
    "avatar_url": "https://media.licdn.com/dms/image/D4D03AQHxd9DuOciHDg/profile-displayphoto-shrink_100_100/0/1684439238428?e=1696464000&v=beta&t=8WR3c4DZyzFbz2Zmh_EexU8MiGKecVE1axCyabTq_hQ",
    "email": "junogouvea@gmail.com",
    "email_verified": true,
    "full_name": "Juan José Gouvêa",
    "iss": "https://api.linkedin.com",
    "name": "Juan José Gouvêa",
    "picture": "https://media.licdn.com/dms/image/D4D03AQHxd9DuOciHDg/profile-displayphoto-shrink_100_100/0/1684439238428?e=1696464000&v=beta&t=8WR3c4DZyzFbz2Zmh_EexU8MiGKecVE1axCyabTq_hQ",
    "provider_id": "hjrQb2hLk7",
    "sub": "hjrQb2hLk7"
  },
  "identities": [
    {
      "id": "hjrQb2hLk7",
      "user_id": "f6c6bea9-3804-4dac-b012-7e56ca0d81b5",
      "identity_data": {
        "avatar_url": "https://media.licdn.com/dms/image/D4D03AQHxd9DuOciHDg/profile-displayphoto-shrink_100_100/0/1684439238428?e=1696464000&v=beta&t=8WR3c4DZyzFbz2Zmh_EexU8MiGKecVE1axCyabTq_hQ",
        "email": "junogouvea@gmail.com",
        "email_verified": true,
        "full_name": "Juan José Gouvêa",
        "iss": "https://api.linkedin.com",
        "name": "Juan José Gouvêa",
        "picture": "https://media.licdn.com/dms/image/D4D03AQHxd9DuOciHDg/profile-displayphoto-shrink_100_100/0/1684439238428?e=1696464000&v=beta&t=8WR3c4DZyzFbz2Zmh_EexU8MiGKecVE1axCyabTq_hQ",
        "provider_id": "hjrQb2hLk7",
        "sub": "hjrQb2hLk7"
      },
      "provider": "linkedin",
      "last_sign_in_at": "2023-08-03T02:51:34.183668Z",
      "created_at": "2023-08-03T02:51:34.183709Z",
      "updated_at": "2023-08-03T02:51:34.183709Z"
    }
  ],
  "created_at": "2023-08-03T02:51:34.181456Z",
  "updated_at": "2023-08-03T02:51:38.095842Z"
}


-------------------

user metadata for github and linkedin mixed (i dont know why my cookies do that)


{
  "id": "ebc9bb0b-5136-4669-8b3b-d94d5f70b17e",
  "aud": "authenticated",
  "role": "authenticated",
  "email": "junogouvea@gmail.com",
  "email_confirmed_at": "2023-08-02T18:58:13.377883Z",
  "phone": "",
  "confirmed_at": "2023-08-02T18:58:13.377883Z",
  "last_sign_in_at": "2023-08-02T20:11:04.956468Z",
  "app_metadata": {
    "provider": "linkedin",
    "providers": [
      "linkedin",
      "github"
    ]
  },
  "user_metadata": {
    "avatar_url": "https://avatars.githubusercontent.com/u/86818341?v=4",
    "email": "junogouvea@gmail.com",
    "email_verified": true,
    "full_name": "Juan José Gouvêa",
    "iss": "https://api.github.com",
    "name": "Juan José Gouvêa",
    "picture": "https://media.licdn.com/dms/image/D4D03AQHxd9DuOciHDg/profile-displayphoto-shrink_100_100/0/1684439238428?e=1696464000&v=beta&t=8WR3c4DZyzFbz2Zmh_EexU8MiGKecVE1axCyabTq_hQ",
    "preferred_username": "junowoz",
    "provider_id": "86818341",
    "sub": "86818341",
    "user_name": "junowoz"
  },
  "identities": [
    {
      "id": "hjrQb2hLk7",
      "user_id": "ebc9bb0b-5136-4669-8b3b-d94d5f70b17e",
      "identity_data": {
        "avatar_url": "https://media.licdn.com/dms/image/D4D03AQHxd9DuOciHDg/profile-displayphoto-shrink_100_100/0/1684439238428?e=1696464000&v=beta&t=8WR3c4DZyzFbz2Zmh_EexU8MiGKecVE1axCyabTq_hQ",
        "email": "junogouvea@gmail.com",
        "email_verified": true,
        "full_name": "Juan José Gouvêa",
        "iss": "https://api.linkedin.com",
        "name": "Juan José Gouvêa",
        "picture": "https://media.licdn.com/dms/image/D4D03AQHxd9DuOciHDg/profile-displayphoto-shrink_100_100/0/1684439238428?e=1696464000&v=beta&t=8WR3c4DZyzFbz2Zmh_EexU8MiGKecVE1axCyabTq_hQ",
        "provider_id": "hjrQb2hLk7",
        "sub": "hjrQb2hLk7"
      },
      "provider": "linkedin",
      "last_sign_in_at": "2023-08-02T18:58:13.373866Z",
      "created_at": "2023-08-02T18:58:13.373911Z",
      "updated_at": "2023-08-02T19:17:00.65367Z"
    },
    {
      "id": "86818341",
      "user_id": "ebc9bb0b-5136-4669-8b3b-d94d5f70b17e",
      "identity_data": {
        "avatar_url": "https://avatars.githubusercontent.com/u/86818341?v=4",
        "email": "junogouvea@gmail.com",
        "email_verified": true,
        "full_name": "Juan José Gouvêa",
        "iss": "https://api.github.com",
        "name": "Juan José Gouvêa",
        "preferred_username": "junowoz",
        "provider_id": "86818341",
        "sub": "86818341",
        "user_name": "junowoz"
      },
      "provider": "github",
      "last_sign_in_at": "2023-08-02T18:59:42.108728Z",
      "created_at": "2023-08-02T18:59:42.108781Z",
      "updated_at": "2023-08-02T20:10:58.305736Z"
    }
  ],
  "created_at": "2023-08-02T18:58:13.36759Z",
  "updated_at": "2023-08-02T20:11:04.958382Z"
}

----------------

google metadata

{
  "id": "9dd2dea0-5421-4e28-ad34-396066b73647",
  "aud": "authenticated",
  "role": "authenticated",
  "email": "junojox@gmail.com",
  "email_confirmed_at": "2023-08-03T02:35:53.538482Z",
  "phone": "",
  "confirmed_at": "2023-08-03T02:35:53.538482Z",
  "last_sign_in_at": "2023-08-03T02:35:57.736917Z",
  "app_metadata": {
    "provider": "google",
    "providers": [
      "google"
    ]
  },
  "user_metadata": {
    "avatar_url": "https://lh3.googleusercontent.com/a/AAcHTtdu6pkj6OBAUG6d_sZyFk0fjaxJpuMUuyfzHtq0fT9JkFI=s96-c",
    "email": "junojox@gmail.com",
    "email_verified": true,
    "full_name": "Juan",
    "iss": "https://accounts.google.com",
    "name": "Juan",
    "picture": "https://lh3.googleusercontent.com/a/AAcHTtdu6pkj6OBAUG6d_sZyFk0fjaxJpuMUuyfzHtq0fT9JkFI=s96-c",
    "provider_id": "102025342708795181907",
    "sub": "102025342708795181907"
  },
  "identities": [
    {
      "id": "102025342708795181907",
      "user_id": "9dd2dea0-5421-4e28-ad34-396066b73647",
      "identity_data": {
        "avatar_url": "https://lh3.googleusercontent.com/a/AAcHTtdu6pkj6OBAUG6d_sZyFk0fjaxJpuMUuyfzHtq0fT9JkFI=s96-c",
        "email": "junojox@gmail.com",
        "email_verified": true,
        "full_name": "Juan",
        "iss": "https://accounts.google.com",
        "name": "Juan",
        "picture": "https://lh3.googleusercontent.com/a/AAcHTtdu6pkj6OBAUG6d_sZyFk0fjaxJpuMUuyfzHtq0fT9JkFI=s96-c",
        "provider_id": "102025342708795181907",
        "sub": "102025342708795181907"
      },
      "provider": "google",
      "last_sign_in_at": "2023-08-03T02:35:53.534392Z",
      "created_at": "2023-08-03T02:35:53.534448Z",
      "updated_at": "2023-08-03T02:35:53.534448Z"
    }
  ],
  "created_at": "2023-08-03T02:35:53.53028Z",
  "updated_at": "2023-08-03T02:35:57.739546Z"
}

--------------------------------------
A forma de autenticação escolhida pelo usuário (Google, GitHub, LinkedIn, etc.) influencia os dados que você recebe. Cada serviço fornece um conjunto único de dados e os chama com nomes diferentes. Por exemplo, o GitHub chama o nome do usuário de user_name, enquanto o Google chama de name. Isso pode levar a conflitos ou incompatibilidades ao combinar esses dados em uma única tabela.

O ideal seria normalizar esses dados antes de inseri-los na tabela. Por exemplo, no seu gatilho, você pode verificar qual provedor o usuário usou para se autenticar e, em seguida, mapear os dados de usuário para um formato comum que você pode usar em toda a sua aplicação.

Aqui está um exemplo de como você poderia fazer isso:


---------------------------------------
declare
  provider text;
  avatar_url text;
begin
  provider := new.raw_app_meta_data->>'provider';

  if provider = 'linkedin' then
    avatar_url := new.raw_user_meta_data->>'picture';
  elsif provider = 'github' then
    avatar_url := new.raw_user_meta_data->>'avatar_url';
  elsif provider = 'google' then
    avatar_url := new.raw_user_meta_data->>'avatar_url';
  end if;

  insert into public.profiles (id, full_name, email, avatar_url)
  values (new.id, new.raw_user_meta_data->>'full_name',new.raw_user_meta_data->>'email', avatar_url);
  insert into public.resumes (profile_id, theme, content)
  values (new.id, 'default', '{}');
  return new;
end;

----------------------------------------
create or replace function public.handle_new_user_with_resume()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  insert into public.resumes (profile_id, theme, content)
  values (new.id, 'default-theme', '{}');
  return new;
end;
$$ language plpgsql security definer;


Aqui, dependendo do provedor, estamos pegando os dados apropriados do raw_user_meta_data e os mapeando para as colunas em nossa tabela de perfis. Tenha em mente que os nomes e estruturas exatas dos dados podem variar dependendo do provedor, então você precisará ajustar este código de acordo com os dados que recebe de cada provedor.

Para obter os dados corretos de cada provedor, você pode fazer uma autenticação de teste com cada um deles e ver a estrutura do raw_user_meta_data que eles fornecem.