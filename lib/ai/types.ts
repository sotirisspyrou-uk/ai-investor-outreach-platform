// /lib/ai/types.ts
// [Version 15-08-2025 14:45:00]

export interface GeneratedHook {
  content: string
  confidence_score: number
  personalization_factors: string[]
  reasoning?: string
}

export interface AIContext {
  investor: {
    name: string
    company: string
    title: string
    sectors: string[]
    recent_activity: string
  }
  company: {
    name: string
    funding_stage: string
    sector: string
    value_prop: string
    funding_target?: string
  }
  campaign: {
    type: string
    platform_preferences: string[]
  }
}

export interface QualityResult {
  passed: GeneratedHook[]
  failed: GeneratedHook[]
  overall_quality: number
}
