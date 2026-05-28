-- =============================================================================
-- Aerchain Vendor Management — 0005 STORAGE + REALTIME
-- Bucket 'vendor-documents' (private). Path convention:
--    vendor-documents/{vendor_id}/{requirement_key-or-uuid}.{ext}
-- Downloads use signed URLs (client: supabase.storage.from(...).createSignedUrl()).
-- =============================================================================

insert into storage.buckets (id, name, public)
values ('vendor-documents','vendor-documents', false)
on conflict (id) do nothing;

-- helper: first path segment as uuid (the vendor_id folder)
create or replace function public.storage_vendor_id(object_name text) returns uuid
language sql immutable as $$
  select nullif((storage.foldername(object_name))[1], '')::uuid;
$$;

-- READ: buyers of the vendor or vendor members
drop policy if exists vdocs_read on storage.objects;
create policy vdocs_read on storage.objects for select to authenticated
using (
  bucket_id = 'vendor-documents'
  and (public.is_buyer_for_vendor(public.storage_vendor_id(name))
       or public.is_vendor_member(public.storage_vendor_id(name)))
);

-- WRITE/UPDATE/DELETE: vendor members (during onboarding) or buyers
drop policy if exists vdocs_insert on storage.objects;
create policy vdocs_insert on storage.objects for insert to authenticated
with check (
  bucket_id = 'vendor-documents'
  and (public.is_vendor_member(public.storage_vendor_id(name))
       or public.is_buyer_for_vendor(public.storage_vendor_id(name)))
);
drop policy if exists vdocs_update on storage.objects;
create policy vdocs_update on storage.objects for update to authenticated
using (
  bucket_id = 'vendor-documents'
  and (public.is_vendor_member(public.storage_vendor_id(name))
       or public.is_buyer_for_vendor(public.storage_vendor_id(name)))
);
drop policy if exists vdocs_delete on storage.objects;
create policy vdocs_delete on storage.objects for delete to authenticated
using (
  bucket_id = 'vendor-documents'
  and (public.is_vendor_member(public.storage_vendor_id(name))
       or public.is_buyer_for_vendor(public.storage_vendor_id(name)))
);

-- =============================================================================
-- REALTIME — publish the tables clients subscribe to (see 07-REALTIME-NOTIFICATIONS.md)
-- =============================================================================
alter publication supabase_realtime add table public.vendors;
alter publication supabase_realtime add table public.vendor_status_history;
alter publication supabase_realtime add table public.vendor_documents;
alter publication supabase_realtime add table public.vendor_messages;
alter publication supabase_realtime add table public.notifications;
alter publication supabase_realtime add table public.vendor_scorecards;
alter publication supabase_realtime add table public.vendor_risk_screenings;

-- full row images on UPDATE/DELETE so client gets old+new
alter table public.vendors                replica identity full;
alter table public.vendor_documents       replica identity full;
alter table public.vendor_messages        replica identity full;
alter table public.notifications          replica identity full;
alter table public.vendor_scorecards      replica identity full;
