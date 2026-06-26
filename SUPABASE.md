# Supabase — Marcadores Mundial App

## Proyecto

- **URL:** `https://gdqfcrwhfceodrnzcdxk.supabase.co`
- **Anon Key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdkcWZjcndoZmNlb2RybnpjZHhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2MTk3NTEsImV4cCI6MjA5NzE5NTc1MX0.l6tAFbQn8G7m3tXZil_LpgwiREFQTYsALRQp4slWt90`

## Tablas

### `profiles`

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | `UUID PK` → `auth.users(id)` | Mismo ID que auth.users |
| `email` | `TEXT` | Email del usuario |
| `nombre` | `TEXT` | Nombre (completado perfil) |
| `apellido` | `TEXT` | Apellido |
| `telefono` | `TEXT` | Teléfono |
| `edad` | `INTEGER` | Edad para filtros por rango |
| `role` | `TEXT` | `user`, `admin`, `moderator`, `editor`, `premium`, `super_admin` |
| `acepta_politicas` | `BOOLEAN` | Aceptó términos |
| `created_at` | `TIMESTAMPTZ` | |
| `updated_at` | `TIMESTAMPTZ` | |

**RLS:** usuarios leen/insertan/updatean su propio perfil. Admin puede leer todos.

### `device_tokens`

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | `UUID PK` | Auto-generado |
| `user_id` | `UUID` → `auth.users(id)` | Dueño del dispositivo |
| `fcm_token` | `TEXT` | Token FCM |
| `device_info` | `TEXT` | `android`, `ios`, `web` |
| `created_at` | `TIMESTAMPTZ` | |
| `updated_at` | `TIMESTAMPTZ` | |

**Unique:** `(user_id, fcm_token)` — permite múltiples dispositivos por usuario.
**RLS:** cada usuario solo CRUD en sus propios tokens.

### `banners`

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | `BIGINT PK` | Identity |
| `image_url` | `TEXT` | URL de la imagen |
| `link_url` | `TEXT` | Link opcional |
| `title` | `TEXT` | Título |
| `is_active` | `BOOLEAN` | Activo/inactivo |
| `display_order` | `INTEGER` | Orden de visualización |
| `created_by` | `UUID` → `auth.users(id)` | Quién lo creó |
| `created_at` / `updated_at` | `TIMESTAMPTZ` | |

**RLS:** anon puede leer activos. Admin/editor pueden CRUD.

### `channels`

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | `BIGINT PK` | Identity |
| `name` | `TEXT` | Nombre del canal |
| `url` | `TEXT` | URL del stream |
| `logo_url` | `TEXT` | Logo opcional |
| `category` | `TEXT` | Categoría |
| `is_active` | `BOOLEAN` | |
| `created_at` / `updated_at` | `TIMESTAMPTZ` | |

**RLS:** anon puede leer activos. Admin CRUD completo.

## Funciones SQL

### `public.is_admin()`

Función `SECURITY DEFINER` que evita recursión infinita en políticas RLS:

```sql
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
$$;
```

Usada en políticas de banners y channels.

## Storage

- **Bucket:** `banners`
- **Público:** lectura pública, escritura solo autenticados
- **Límite:** 5 MB, formatos PNG/JPG/WebP

## Edge Function: `send-notification`

Envía push notifications vía FCM a usuarios según target.

### Endpoint

```
POST https://gdqfcrwhfceodrnzcdxk.supabase.co/functions/v1/send-notification
Authorization: Bearer ANON_KEY
Content-Type: application/json
```

### Payload

```json
{
  "title": "Título",
  "body": "Cuerpo del mensaje",
  "data": { "route": "/page" },
  "target": {
    "type": "all" | "age_range" | "user",
    "userId": "UUID",
    "minAge": 18,
    "maxAge": 25
  }
}
```

### Response

```json
{ "sent": 5, "failed": 0, "cleaned": 0 }
```

- `sent` — notificaciones enviadas ok
- `failed` — fallaron
- `cleaned` — tokens inválidos eliminados de `device_tokens`

### Secrets requeridos

| Secret | Valor |
|--------|-------|
| `FIREBASE_SERVICE_ACCOUNT` | JSON completo del service account de Firebase Admin SDK |

### Deploy

```bash
supabase functions deploy send-notification --use-api
```

### Cómo se registran los tokens

1. `FcmService.initialize()` en `lib/data/services/fcm_service.dart` pide permiso y obtiene token
2. Cuando `AuthCubit` emite `authenticated`, `saveToken()` upserta el token en `device_tokens`
3. En cada inicio de sesión se refresca el `updated_at`
4. Si el token cambia, `onTokenRefresh` lo actualiza

## Flujo de Autenticación

```
App inicia → checkSession()
  ├─ ¿Tiene sesión?
  │   ├─ No → guest (ve Home, Media, Settings, Login)
  │   └─ Sí →
  │       ├─ ¿Email confirmado?
  │       │   ├─ No → EmailVerificationPage
  │       │   └─ Sí →
  │       │       ├─ ¿Perfil completo?
  │       │       │   ├─ No → CompleteProfilePage
  │       │       │   └─ Sí → authenticated (perfil, admin, etc.)
```

## SQL Files

| Archivo | Propósito |
|---------|-----------|
| `supabase_auth_profiles.sql` | Tabla `profiles`, RLS, `is_admin()`, banners/channels RLS, storage |
| `supabase_banners.sql` | Tabla `banners` original |
| `supabase_banners_crud.sql` | `profiles` versión anterior + roles admin/editor |
| `supabase_storage_banners.sql` | Storage bucket banners |
| `supabase_device_tokens.sql` | Tabla `device_tokens` para notificaciones push |
| `supabase/functions/send-notification/scheduled.sql` | Tabla `scheduled_notifications` + cron |

## CLI

```bash
# Link project
supabase link --project-ref gdqfcrwhfceodrnzcdxk

# Set secrets
supabase secrets set FIREBASE_SERVICE_ACCOUNT='{...}'

# Deploy function
supabase functions deploy send-notification --use-api

# Pull remote DB schema (for local dev)
supabase db pull
```
