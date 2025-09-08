# AI System Wrapper Implementation Plan

## Overview

This document outlines the proposed approach for creating a wrapper system around the AI investor outreach prompt to enable seamless integration with the Next.js application, provide context management, and ensure reliable AI interactions.

## Wrapper Architecture

### Core Components

```typescript
// /lib/ai/ai-wrapper.ts
export class AIWrapper {
  private client: OpenAI | Anthropic
  private systemPrompt: string
  private contextManager: ContextManager
  private qualityChecker: QualityChecker
  private performanceTracker: PerformanceTracker
}
```

### 1. Context Management Layer

**Purpose:** Maintain conversation state and provide relevant context to AI calls

```typescript
interface ContextManager {
  // Investor context
  investor_profile: InvestorProfile
  enrichment_data: EnrichmentData
  interaction_history: InteractionHistory[]
  
  // Company context  
  company_profile: CompanyProfile
  campaign_settings: CampaignSettings
  
  // Session context
  user_preferences: UserPreferences
  current_session: SessionData
}

class ContextManager {
  async buildContext(
    investorId: string,
    companyId: string,
    campaignId: string
  ): Promise<AIContext> {
    const investor = await this.getInvestorProfile(investorId)
    const enrichment = await this.getEnrichmentData(investorId)
    const company = await this.getCompanyProfile(companyId)
    const campaign = await this.getCampaignSettings(campaignId)
    
    return {
      investor: this.formatInvestorContext(investor, enrichment),
      company: this.formatCompanyContext(company),
      campaign: this.formatCampaignContext(campaign),
      instructions: this.getSpecificInstructions(campaign.type)
    }
  }
}
```

### 2. Prompt Construction Engine

**Purpose:** Dynamically build AI prompts with context and specific instructions

```typescript
class PromptBuilder {
  private systemPrompt: string
  private templates: PromptTemplates
  
  async buildHookGenerationPrompt(context: AIContext): Promise<string> {
    return `
    ${this.systemPrompt}
    
    ## Current Task: Generate Personalized Investment Outreach Hook
    
    ### Investor Profile:
    - Name: ${context.investor.name}
    - Company: ${context.investor.company}
    - Title: ${context.investor.title}
    - Investment Focus: ${context.investor.sectors.join(', ')}
    - Recent Activity: ${this.summarizeRecentActivity(context.investor.activity)}
    
    ### Company Context:
    - Company: ${context.company.name}
    - Stage: ${context.company.funding_stage}
    - Sector: ${context.company.sector}
    - Value Proposition: ${context.company.value_prop}
    - Fundraising Goal: ${context.company.funding_target}
    
    ### Output Format:
    Return a JSON object with the following structure:
    {
      "hooks": [
        {
          "content": "personalized hook text",
          "confidence_score": 0.85,
          "personalization_factors": ["recent_activity", "investment_thesis"],
          "reasoning": "explanation of approach"
        }
      ]
    }
    `
  }
}
```

## Implementation Strategy

### Phase 1: Core Wrapper (Week 1)
```typescript
// /lib/ai/investor-outreach-ai.ts
export class InvestorOutreachAI {
  constructor(
    private aiClient: OpenAI | Anthropic,
    private database: SupabaseClient
  ) {}
  
  async generateHooks(
    investorId: string,
    companyId: string,
    campaignId: string
  ): Promise<GeneratedHook[]> {
    try {
      // 1. Build context
      const context = await this.contextManager.buildContext(
        investorId, companyId, campaignId
      )
      
      // 2. Generate prompt
      const prompt = await this.promptBuilder.buildHookGenerationPrompt(context)
      
      // 3. Call AI service
      const response = await this.aiClient.chat.completions.create({
        model: "gpt-4",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.7,
        max_tokens: 500
      })
      
      // 4. Parse and validate response
      const hooks = this.parseHookResponse(response.choices[0].message.content)
      const validated = await this.qualityChecker.validateHookQuality(hooks, context)
      
      return validated.passed
      
    } catch (error) {
      return this.errorHandler.handleAIFailure(error, context)
    }
  }
}
```

## Success Metrics

### Wrapper Performance
- **Response Time:** < 3 seconds for hook generation
- **Success Rate:** 95%+ successful AI calls
- **Quality Rate:** 90%+ hooks pass quality validation
- **Error Recovery:** 80%+ errors handled gracefully

### Business Impact
- **Hook Quality:** 90%+ reference specific investor activity
- **Response Correlation:** AI confidence scores correlate with actual response rates
- **Time Efficiency:** 80% reduction in manual hook creation time
- **Consistency:** Consistent quality across all generated content

This wrapper approach ensures reliable, high-quality AI integration while providing the flexibility to adapt and improve the system based on real-world performance data.
