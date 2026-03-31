import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

const SUPABASE_URL = "https://wduqrkpokfhqpumfkwrm.supabase.co";
const SUPABASE_ANON_KEY =
  "sb_publishable_AGEZQw_KtVkhb1OV8EY2JQ_2jkBcHz7";

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
