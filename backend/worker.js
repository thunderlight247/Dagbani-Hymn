/**
 * PCG Dagbani Hymn – Churches Cloudflare Worker
 * Clean slate: no seed data. All churches are user-submitted.
 */

// In-memory store (replace with KV binding for persistence across deployments)
let memChurches = [];

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const path = url.pathname;
    const method = request.method;

    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    if (method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // ── GET /churches ──────────────────────────────────────────────────────
    if (method === 'GET' && path === '/churches') {
      // Try KV first; fall back to in-memory
      let churches = memChurches;
      if (env.CHURCHES_KV) {
        try {
          const stored = await env.CHURCHES_KV.get('churches', 'json');
          if (stored) churches = stored;
        } catch (_) {}
      }
      return new Response(
        JSON.stringify({ churches }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // ── POST /churches ─────────────────────────────────────────────────────
    if (method === 'POST' && path === '/churches') {
      let body;
      try { body = await request.json(); }
      catch { return new Response('Invalid JSON', { status: 400, headers: corsHeaders }); }

      if (!body.name || !body.townCity) {
        return new Response('name and townCity are required', { status: 422, headers: corsHeaders });
      }

      const church = {
        id: body.id ?? Date.now().toString(),
        name: body.name,
        townCity: body.townCity,
        presbytery: body.presbytery ?? '',
        locationDescription: body.locationDescription ?? '',
        googleMapsUrl: body.googleMapsUrl ?? '',
        minister: body.minister ?? '',
        contactPhone: body.contactPhone ?? '',
        activities: body.activities ?? '',
        uploadedBy: body.uploadedBy ?? '',
        createdAt: body.createdAt ?? new Date().toISOString(),
      };

      memChurches = memChurches.filter(c => c.id !== church.id);
      memChurches.push(church);

      if (env.CHURCHES_KV) {
        try { await env.CHURCHES_KV.put('churches', JSON.stringify(memChurches)); }
        catch (_) {}
      }

      return new Response(
        JSON.stringify({ success: true, church }),
        { status: 201, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // ── PUT /churches/:id ──────────────────────────────────────────────────
    const putMatch = path.match(/^\/churches\/(.+)$/);
    if (method === 'PUT' && putMatch) {
      const id = putMatch[1];
      let body;
      try { body = await request.json(); }
      catch { return new Response('Invalid JSON', { status: 400, headers: corsHeaders }); }

      const idx = memChurches.findIndex(c => c.id === id);
      if (idx === -1) {
        return new Response('Church not found', { status: 404, headers: corsHeaders });
      }
      memChurches[idx] = { ...memChurches[idx], ...body, id };

      if (env.CHURCHES_KV) {
        try { await env.CHURCHES_KV.put('churches', JSON.stringify(memChurches)); }
        catch (_) {}
      }

      return new Response(
        JSON.stringify({ success: true, church: memChurches[idx] }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    return new Response('Not Found', { status: 404, headers: corsHeaders });
  },
};
