# Claude Code Development Guide

## Project Overview
This repository contains the scaffolding and documentation for an AI-powered investor outreach automation platform. The system uses AI to personalise cold outreach to investors, increasing response rates from 2-3% to 15-20%.

## Architecture Summary

### Technology Stack
- **Frontend:** Next.js 15.1.7, React 18.2.0, Tailwind CSS 3.4.17
- **Backend:** Supabase (PostgreSQL, Authentication, Real-time)
- **AI Integration:** OpenAI GPT-4 or Anthropic Claude
- **State Management:** Zustand
- **Form Handling:** React Hook Form + Zod validation
- **Deployment:** Vercel

### Core Components
```
/app
├── /dashboard          # Main application interface
├── /campaigns         # Campaign management
├── /investors         # Investor database management
├── /analytics         # Performance tracking
└── /settings          # User configuration

/components
├── /ui                # Reusable UI components
├── /forms             # Form components
├── /charts            # Analytics visualizations
└── /automation        # Outreach automation controls

/lib
├── /ai                # AI integration utilities
├── /database          # Supabase client and queries
├── /integrations      # External API handlers
└── /utils             # Helper functions
```

## Key Development Priorities

### Phase 1: Core Infrastructure (Weeks 1-3)
1. **Database Schema Setup**
   - Investors table with contact information
   - Campaigns table for outreach management
   - Messages table for tracking communications
   - Analytics tables for performance metrics

2. **Authentication & User Management**
   - Supabase Auth integration
   - User roles and permissions
   - Account settings and preferences

3. **Basic CRUD Operations**
   - Investor management (import, edit, delete)
   - Campaign creation and management
   - Message templates and customization

### Phase 2: AI Integration (Weeks 4-6)
1. **Data Enrichment Pipeline**
   - LinkedIn profile scraping
   - X/Twitter activity analysis
   - Content summarization and analysis
   - Investor preference extraction

2. **Hook Generation Engine**
   - AI prompt engineering for personalization
   - Quality scoring and validation
   - A/B testing framework
   - Template management system

3. **Platform Optimization**
   - Response rate prediction
   - Platform preference scoring
   - Timing optimization
   - Success pattern analysis

## Critical Implementation Notes

### Security & Compliance
- **GDPR Compliance:** Implement consent management and data deletion
- **Platform ToS:** Respect rate limits for LinkedIn, X, email
- **Data Protection:** Encrypt sensitive investor information
- **API Security:** Implement proper authentication and rate limiting

### Performance Considerations
- **Database Optimization:** Index frequently queried fields
- **AI Cost Management:** Implement caching for repeated queries
- **Rate Limiting:** Prevent platform violations through intelligent throttling
- **Error Handling:** Graceful degradation when external APIs fail

### Code Quality Standards
```typescript
// Always include file path and version
// /app/dashboard/campaigns/route.ts
// [Version 15-08-2025 14:45:00]

// Use TypeScript for all components
interface InvestorProfile {
  id: string;
  name: string;
  email: string;
  linkedin_url?: string;
  twitter_handle?: string;
  investment_stages: string[];
  sectors: string[];
}

// Implement proper error boundaries
try {
  const response = await generateHook(investor, company);
  return response;
} catch (error) {
  console.error('Hook generation failed:', error);
  throw new Error('Failed to generate personalized message');
}
```

## Development Workflow

### 1. Environment Setup
```bash
# Clone repository
git clone https://github.com/sotirisspyrou-uk/ai-investor-outreach-platform
cd ai-investor-outreach-platform

# Install dependencies
npm install

# Setup environment variables
cp .env.example .env.local
# Configure Supabase, OpenAI, and other API keys

# Run development server
npm run dev
```

### 2. Database Setup
```sql
-- Run these scripts in Supabase SQL editor
-- /database/schema.sql contains full table definitions
-- /database/seed.sql contains sample data for testing
```

### 3. Testing Strategy
```bash
# Run unit tests
npm run test

# Run integration tests
npm run test:integration

# Run E2E tests
npm run test:e2e
```

## API Integration Guidelines

### AI Services Integration
```typescript
// /lib/ai/hook-generator.ts
export async function generateHook(
  investor: InvestorProfile,
  company: CompanyProfile
): Promise<GeneratedHook> {
  const prompt = buildPersonalizationPrompt(investor, company);
  const response = await openai.chat.completions.create({
    model: "gpt-4",
    messages: [{ role: "user", content: prompt }],
    max_tokens: 200,
    temperature: 0.7
  });
  
  return {
    content: response.choices[0].message.content,
    confidence: calculateConfidenceScore(response),
    personalization_factors: extractFactors(investor)
  };
}
```

## Common Issues & Solutions

### Database Connection Issues
```typescript
// Ensure proper Supabase client initialization
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
```

### AI API Rate Limiting
```typescript
// Implement exponential backoff for API calls
async function makeAIRequest(prompt: string, retries = 3): Promise<string> {
  try {
    return await openai.chat.completions.create({...});
  } catch (error) {
    if (retries > 0 && error.status === 429) {
      await new Promise(resolve => setTimeout(resolve, 2000 * (4 - retries)));
      return makeAIRequest(prompt, retries - 1);
    }
    throw error;
  }
}
```

## Next Steps for Development
1. Set up the basic Next.js project structure
2. Configure Supabase database and authentication
3. Implement core investor management features
4. Build AI integration for hook generation
5. Add automation capabilities for outreach
6. Create analytics dashboard for performance tracking

---

**Note:** This is a portfolio demonstration project. All sensitive data and API keys should be properly secured and never committed to the repository.
