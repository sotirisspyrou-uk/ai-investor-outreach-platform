-- Sample data for AI Investor Outreach Platform
-- [Version 15-08-2025 14:45:00]

-- Insert sample investors
INSERT INTO investors (first_name, last_name, email, linkedin_url, company, title, investment_stages, sectors) VALUES
('Sarah', 'Chen', 'sarah@benchmark.com', 'https://linkedin.com/in/sarahchen', 'Benchmark Capital', 'Partner', '["seed", "series-a"]', '["fintech", "ai"]'),
('Michael', 'Rodriguez', 'michael@a16z.com', 'https://linkedin.com/in/mrodriguez', 'Andreessen Horowitz', 'General Partner', '["series-a", "series-b"]', '["crypto", "ai", "healthtech"]'),
('Emma', 'Thompson', 'emma@sequoiacap.com', 'https://linkedin.com/in/emmathompson', 'Sequoia Capital', 'Principal', '["pre-seed", "seed"]', '["fintech", "enterprise"]');

-- Insert sample enrichment data
INSERT INTO investor_enrichment (investor_id, source, data_type, content, sentiment_score, relevance_score) VALUES
((SELECT id FROM investors WHERE email = 'sarah@benchmark.com'), 'linkedin', 'post', 'Excited about the future of AI in financial services. The intersection of regulatory compliance and machine learning is fascinating.', 0.8, 0.9),
((SELECT id FROM investors WHERE email = 'michael@a16z.com'), 'twitter', 'tweet', 'Just finished reading about the latest developments in crypto infrastructure. The space is evolving rapidly.', 0.7, 0.8),
((SELECT id FROM investors WHERE email = 'emma@sequoiacap.com'), 'linkedin', 'comment', 'Great point about enterprise adoption cycles. B2B companies need to focus on demonstrable ROI from day one.', 0.6, 0.85);

-- Insert sample campaign
INSERT INTO campaigns (name, status, target_count, created_by) VALUES
('Q4 2025 Fundraising Campaign', 'active', 3, uuid_generate_v4());

-- Insert sample outreach sequences
INSERT INTO outreach_sequences (campaign_id, investor_id, status, primary_platform, selected_hook) VALUES
((SELECT id FROM campaigns WHERE name = 'Q4 2025 Fundraising Campaign'), 
 (SELECT id FROM investors WHERE email = 'sarah@benchmark.com'), 
 'active', 
 'linkedin', 
 'Saw your recent post about AI in financial services - our regulatory compliance automation platform directly addresses the challenges you mentioned.');
