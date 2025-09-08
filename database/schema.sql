-- AI Investor Outreach Platform Database Schema
-- [Version 15-08-2025 14:45:00]

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Investors table
CREATE TABLE investors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    linkedin_url VARCHAR(500),
    twitter_handle VARCHAR(100),
    company VARCHAR(200),
    title VARCHAR(200),
    investment_stages JSONB DEFAULT '[]'::jsonb,
    sectors JSONB DEFAULT '[]'::jsonb,
    geographies JSONB DEFAULT '[]'::jsonb,
    last_enriched TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Investor enrichment data table
CREATE TABLE investor_enrichment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    investor_id UUID REFERENCES investors(id) ON DELETE CASCADE,
    source VARCHAR(50) NOT NULL,
    data_type VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    sentiment_score DECIMAL(3,2),
    relevance_score DECIMAL(3,2),
    extracted_at TIMESTAMP DEFAULT NOW()
);

-- Campaigns table
CREATE TABLE campaigns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    status VARCHAR(50) DEFAULT 'draft',
    target_count INTEGER DEFAULT 0,
    completed_count INTEGER DEFAULT 0,
    response_rate DECIMAL(5,2) DEFAULT 0.00,
    created_by UUID NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Outreach sequences table
CREATE TABLE outreach_sequences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    campaign_id UUID REFERENCES campaigns(id) ON DELETE CASCADE,
    investor_id UUID REFERENCES investors(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'pending',
    primary_platform VARCHAR(20),
    hooks_generated JSONB DEFAULT '[]'::jsonb,
    selected_hook TEXT,
    current_touch INTEGER DEFAULT 0,
    last_contact_at TIMESTAMP NULL,
    response_received BOOLEAN DEFAULT FALSE,
    meeting_booked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Messages table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sequence_id UUID REFERENCES outreach_sequences(id) ON DELETE CASCADE,
    platform VARCHAR(20) NOT NULL,
    message_type VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    sent_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    opened_at TIMESTAMP NULL,
    responded_at TIMESTAMP NULL,
    response_content TEXT,
    response_sentiment VARCHAR(20)
);

-- Analytics table
CREATE TABLE analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    campaign_id UUID REFERENCES campaigns(id) ON DELETE CASCADE,
    metric_type VARCHAR(50) NOT NULL,
    metric_value DECIMAL(10,2) NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    recorded_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_investors_email ON investors(email);
CREATE INDEX idx_investors_company ON investors(company);
CREATE INDEX idx_enrichment_investor_id ON investor_enrichment(investor_id);
CREATE INDEX idx_enrichment_source ON investor_enrichment(source);
CREATE INDEX idx_campaigns_status ON campaigns(status);
CREATE INDEX idx_sequences_campaign_id ON outreach_sequences(campaign_id);
CREATE INDEX idx_sequences_status ON outreach_sequences(status);
CREATE INDEX idx_messages_sequence_id ON messages(sequence_id);
CREATE INDEX idx_messages_platform ON messages(platform);
CREATE INDEX idx_analytics_campaign_id ON analytics(campaign_id);
CREATE INDEX idx_analytics_metric_type ON analytics(metric_type);

-- RLS (Row Level Security) policies
ALTER TABLE investors ENABLE ROW LEVEL SECURITY;
ALTER TABLE investor_enrichment ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE outreach_sequences ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics ENABLE ROW LEVEL SECURITY;

-- Create policies (basic user-based access)
CREATE POLICY "Users can view their own investors" ON investors
    FOR SELECT USING (auth.uid()::text = created_by::text);

CREATE POLICY "Users can insert their own investors" ON investors
    FOR INSERT WITH CHECK (auth.uid()::text = created_by::text);

CREATE POLICY "Users can update their own investors" ON investors
    FOR UPDATE USING (auth.uid()::text = created_by::text);

-- Add missing created_by column to investors
ALTER TABLE investors ADD COLUMN created_by UUID DEFAULT auth.uid();

-- Update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER trigger_investors_updated_at
    BEFORE UPDATE ON investors
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();
