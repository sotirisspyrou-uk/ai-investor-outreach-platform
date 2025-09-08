// /lib/database/supabase.ts
// [Version 15-08-2025 14:45:00]

import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Database types
export interface InvestorProfile {
  id: string
  first_name: string
  last_name: string
  email?: string
  linkedin_url?: string
  twitter_handle?: string
  company?: string
  title?: string
  investment_stages: string[]
  sectors: string[]
  geographies: string[]
  last_enriched?: string
  created_at: string
  updated_at: string
}

export interface Campaign {
  id: string
  name: string
  status: 'draft' | 'active' | 'paused' | 'completed'
  target_count: number
  completed_count: number
  response_rate: number
  created_by: string
  created_at: string
}

export interface OutreachSequence {
  id: string
  campaign_id: string
  investor_id: string
  status: 'pending' | 'active' | 'responded' | 'completed'
  primary_platform: 'linkedin' | 'twitter' | 'email'
  hooks_generated: Array<{
    content: string
    confidence_score: number
    personalization_factors: string[]
  }>
  selected_hook?: string
  current_touch: number
  last_contact_at?: string
  response_received: boolean
  meeting_booked: boolean
  created_at: string
}
