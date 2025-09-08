# AI System Wrapper Implementation Plan
**File Path:** `//documents/Wrapper-Plan_15082025.md`
**Version:** [15-08-2025 14:30:00]
**Authored by:** Sotiris Spyrou, CEO, VerityAI
**Contact:** sotiris@verityai.co | https://www.linkedin.com/in/sspyrou/

---

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
    
    ### Specific Instructions:
    ${this.getTaskSpecificInstructions('hook_generation')}
    
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
  
  async buildResponseAnalysisPrompt(
    context: AIContext,
    responseText: string
  ): Promise<string> {
    return `
    ${this.systemPrompt}
    
    ## Current Task: Analyze Investor Response
    
    ### Original Message Context:
    ${context.original_message}
    
    ### Investor Response:
    "${responseText}"
    
    ### Analysis Required:
    - Sentiment classification (positive/neutral/negative)
    - Interest level (high/medium/low/none)
    - Response type (meeting_request/question/objection/rejection)
    - Recommended next action
    
    ${this.getTaskSpecificInstructions('response_analysis')}
    `
  }
}
```

### 3. Quality Assurance Layer

**Purpose:** Validate AI outputs before delivery to ensure quality standards

```typescript
class QualityChecker {
  async validateHookQuality(
    hooks: GeneratedHook[],
    context: AIContext
  ): Promise<QualityResult> {
    const results = await Promise.all(
      hooks.map(hook => this.validateSingleHook(hook, context))
    )
    
    return {
      passed: results.filter(r => r.passed),
      failed: results.filter(r => !r.passed),
      overall_quality: this.calculateOverallQuality(results)
    }
  }
  
  private async validateSingleHook(
    hook: GeneratedHook,
    context: AIContext
  ): Promise<ValidationResult> {
    const checks = {
      specificity: await this.checkSpecificity(hook, context.investor),
      relevance: await this.checkRelevance(hook, context.company),
      authenticity: await this.checkAuthenticity(hook),
      length: this.checkLength(hook.content),
      compliance: await this.checkCompliance(hook)
    }
    
    return {
      passed: Object.values(checks).every(check => check.passed),
      checks: checks,
      overall_score: this.calculateScore(checks)
    }
  }
  
  private async checkSpecificity(
    hook: GeneratedHook,
    investor: InvestorContext
  ): Promise<CheckResult> {
    // Verify hook references specific investor activity
    const references = this.extractReferences(hook.content)
    const verified = await this.verifyReferences(references, investor.activity)
    
    return {
      passed: verified.length > 0,
      score: verified.length / references.length,
      details: `${verified.length}/${references.length} references verified`
    }
  }
}
```

### 4. Performance Tracking & Analytics

**Purpose:** Monitor AI performance and provide optimization insights

```typescript
class PerformanceTracker {
  async trackHookGeneration(
    request: HookGenerationRequest,
    response: HookGenerationResponse,
    metadata: RequestMetadata
  ): Promise<void> {
    await this.database.performance_logs.insert({
      request_id: metadata.request_id,
      investor_id: request.investor_id,
      company_id: request.company_id,
      hooks_generated: response.hooks.length,
      avg_confidence: this.calculateAvgConfidence(response.hooks),
      processing_time: metadata.processing_time,
      quality_score: response.quality_score,
      timestamp: new Date()
    })
  }
  
  async getPerformanceMetrics(timeframe: string): Promise<PerformanceMetrics> {
    return {
      avg_confidence: await this.getAvgConfidence(timeframe),
      avg_processing_time: await this.getAvgProcessingTime(timeframe),
      quality_trends: await this.getQualityTrends(timeframe),
      success_rate: await this.getSuccessRate(timeframe)
    }
  }
}
```

### 5. Error Handling & Fallback System

**Purpose:** Gracefully handle AI failures and provide alternative solutions

```typescript
class ErrorHandler {
  async handleAIFailure(
    error: AIError,
    context: AIContext,
    retryCount: number = 0
  ): Promise<AIResponse> {
    // Log error for analysis
    await this.logError(error, context, retryCount)
    
    // Determine fallback strategy
    switch (error.type) {
      case 'API_RATE_LIMIT':
        return this.handleRateLimit(context, retryCount)
      
      case 'QUALITY_FAILURE':
        return this.handleQualityFailure(context, retryCount)
      
      case 'NETWORK_ERROR':
        return this.handleNetworkError(context, retryCount)
      
      default:
        return this.handleGenericError(context, retryCount)
    }
  }
  
  private async handleRateLimit(
    context: AIContext,
    retryCount: number
  ): Promise<AIResponse> {
    if (retryCount < 3) {
      // Exponential backoff
      const delay = Math.pow(2, retryCount) * 1000
      await new Promise(resolve => setTimeout(resolve, delay))
      return this.retryRequest(context, retryCount + 1)
    }
    
    // Fallback to template-based approach
    return this.generateTemplateResponse(context)
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
      
      // 5. Track performance
      await this.performanceTracker.trackHookGeneration(
        { investorId, companyId, campaignId },
        validated,
        { processing_time: Date.now() - startTime }
      )
      
      return validated.passed
      
    } catch (error) {
      return this.errorHandler.handleAIFailure(error, context)
    }
  }
}
```

### Phase 2: Advanced Features (Week 2)
- Response analysis capabilities
- Dynamic prompt optimization
- A/B testing framework
- Performance analytics dashboard

### Phase 3: Integration & Testing (Week 3)
- Frontend component integration
- End-to-end testing
- Performance optimization
- Production deployment

## API Interface Design

### Hook Generation Endpoint
```typescript
// /app/api/ai/generate-hooks/route.ts
export async function POST(request: Request) {
  const { investorId, companyId, campaignId } = await request.json()
  
  const ai = new InvestorOutreachAI(openai, supabase)
  const hooks = await ai.generateHooks(investorId, companyId, campaignId)
  
  return NextResponse.json({
    success: true,
    hooks: hooks,
    metadata: {
      generated_at: new Date(),
      confidence_range: [
        Math.min(...hooks.map(h => h.confidence_score)),
        Math.max(...hooks.map(h => h.confidence_score))
      ]
    }
  })
}
```

### Response Analysis Endpoint
```typescript
// /app/api/ai/analyze-response/route.ts
export async function POST(request: Request) {
  const { sequenceId, responseText } = await request.json()
  
  const ai = new InvestorOutreachAI(openai, supabase)
  const analysis = await ai.analyzeResponse(sequenceId, responseText)
  
  return NextResponse.json({
    success: true,
    analysis: analysis,
    recommended_action: analysis.next_action
  })
}
```

## Configuration Management

### Environment-based Configuration
```typescript
// /lib/ai/config.ts
export const AIConfig = {
  development: {
    model: "gpt-4",
    temperature: 0.8,
    max_tokens: 500,
    retry_attempts: 2
  },
  production: {
    model: "gpt-4",
    temperature: 0.7,
    max_tokens: 400,
    retry_attempts: 3
  }
}[process.env.NODE_ENV || 'development']
```

### Feature Flags
```typescript
export const AIFeatures = {
  ADVANCED_PERSONALIZATION: true,
  RESPONSE_ANALYSIS: true,
  QUALITY_ENFORCEMENT: true,
  PERFORMANCE_TRACKING: true,
  A_B_TESTING: process.env.NODE_ENV === 'production'
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
