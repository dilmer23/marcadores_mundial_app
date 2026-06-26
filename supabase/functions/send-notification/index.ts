import { createClient } from 'jsr:@supabase/supabase-js@2';
import jwt from 'npm:jsonwebtoken@9';

interface Payload {
  title: string;
  body: string;
  data?: Record<string, string>;
  target: {
    type: 'all' | 'age_range' | 'user';
    userId?: string;
    minAge?: number;
    maxAge?: number;
  };
}

const CONCURRENCY = 50;

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  try {
    const payload: Payload = await req.json();
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // 1. Resolve target user_ids
    let userIds: string[] | null = null;
    if (payload.target.type === 'user') {
      userIds = [payload.target.userId!];
    } else if (payload.target.type === 'age_range') {
      let q = supabase.from('profiles').select('id');
      if (payload.target.minAge != null) q = q.gte('edad', payload.target.minAge);
      if (payload.target.maxAge != null) q = q.lte('edad', payload.target.maxAge);
      const { data: profiles } = await q;
      userIds = (profiles ?? []).map((p: any) => p.id);
    }

    // 2. Fetch device tokens
    let tq = supabase.from('device_tokens').select('fcm_token');
    if (userIds) tq = tq.in('user_id', userIds);
    const { data: tokens, error: dbErr } = await tq;
    if (dbErr) throw dbErr;

    const tokenList: string[] = (tokens ?? []).map((t: any) => t.fcm_token);
    if (tokenList.length === 0) {
      return new Response(JSON.stringify({ sent: 0, failed: 0 }));
    }

    // 3. Get OAuth2 access token
    const sa = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT')!);
    const now = Math.floor(Date.now() / 1000);
    const assertion = jwt.sign(
      {
        iss: sa.client_email,
        scope: 'https://www.googleapis.com/auth/firebase.messaging',
        aud: 'https://oauth2.googleapis.com/token',
        exp: now + 3600,
        iat: now,
      },
      sa.private_key,
      { algorithm: 'RS256' },
    );

    const tr = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({ grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion }),
    });
    const { access_token } = await tr.json();

    // 4. Send concurrently with rate limiting
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`;
    let sent = 0;
    const invalidTokens: string[] = [];

    async function sendToken(token: string) {
      const res = await fetch(fcmUrl, {
        method: 'POST',
        headers: { Authorization: `Bearer ${access_token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: { token, notification: { title: payload.title, body: payload.body }, data: payload.data ?? {} },
        }),
      });
      if (!res.ok) {
        const body = await res.json();
        if (body.error?.status === 'UNREGISTERED' || body.error?.status === 'NOT_FOUND') {
          invalidTokens.push(token);
        }
        return false;
      }
      return true;
    }

    for (let i = 0; i < tokenList.length; i += CONCURRENCY) {
      const batch = tokenList.slice(i, i + CONCURRENCY);
      const results = await Promise.all(batch.map(sendToken));
      sent += results.filter(Boolean).length;
    }

    // 5. Remove invalid tokens
    if (invalidTokens.length > 0) {
      await supabase.from('device_tokens').delete().in('fcm_token', invalidTokens);
    }

    return new Response(JSON.stringify({ sent, failed: tokenList.length - sent, cleaned: invalidTokens.length }));
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});
