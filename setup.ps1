New-Item -ItemType Directory -Force -Path "src\routes" | Out-Null

Set-Content -Path "package.json" -Encoding UTF8 -Value '{
  "name": "funnel-capa-a-capa",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": { "start": "node server.js", "dev": "nodemon server.js" },
  "dependencies": { "axios": "^1.7.2", "cors": "^2.8.5", "dotenv": "^16.4.5", "express": "^4.19.2" },
  "devDependencies": { "nodemon": "^3.1.4" }
}'

Set-Content -Path ".env.example" -Encoding UTF8 -Value 'META_APP_ID=your_app_id_here
META_APP_SECRET=your_app_secret_here
META_ACCESS_TOKEN=your_long_lived_access_token_here
META_AD_ACCOUNT_ID=act_your_ad_account_id_here
META_API_VERSION=v21.0
PORT=3000'

Set-Content -Path ".gitignore" -Encoding UTF8 -Value 'node_modules/
.env
*.log'

Set-Content -Path "server.js" -Encoding UTF8 -Value "require('dotenv').config();
const express = require('express');
const cors = require('cors');
const campaignsRouter = require('./src/routes/campaigns');
const adsRouter = require('./src/routes/ads');
const metricsRouter = require('./src/routes/metrics');
const audiencesRouter = require('./src/routes/audiences');
const app = express();
app.use(cors());
app.use(express.json());
app.get('/api/health', (req, res) => {
  const configured = !!(process.env.META_ACCESS_TOKEN && process.env.META_AD_ACCOUNT_ID);
  res.json({ status: 'ok', meta_configured: configured, api_version: process.env.META_API_VERSION || 'v21.0' });
});
app.use('/api/campaigns', campaignsRouter);
app.use('/api/ads', adsRouter);
app.use('/api/metrics', metricsRouter);
app.use('/api/audiences', audiencesRouter);
app.use((err, req, res, next) => {
  res.status(err.status || 500).json({ error: err.message, code: err.code });
});
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log('Servidor corriendo en http://localhost:' + PORT));"

Set-Content -Path "src\meta.js" -Encoding UTF8 -Value "const axios = require('axios');
const metaClient = axios.create({ baseURL: 'https://graph.facebook.com/' + (process.env.META_API_VERSION || 'v21.0'), timeout: 30000 });
metaClient.interceptors.request.use((config) => { config.params = { ...config.params, access_token: process.env.META_ACCESS_TOKEN }; return config; });
metaClient.interceptors.response.use((res) => res, (err) => { const e = err.response?.data?.error; if (e) { const error = new Error(e.message); error.code = e.code; error.type = e.type; error.status = err.response.status; return Promise.reject(error); } return Promise.reject(err); });
module.exports = metaClient;"

Set-Content -Path "src\routes\campaigns.js" -Encoding UTF8 -Value "const { Router } = require('express');
const meta = require('../meta');
const router = Router();
const aid = () => process.env.META_AD_ACCOUNT_ID;
router.get('/', async (req, res, next) => { try { const { data } = await meta.get('/' + aid() + '/campaigns', { params: { fields: 'id,name,status,objective,daily_budget,lifetime_budget,start_time,stop_time,created_time', limit: req.query.limit || 25 } }); res.json(data); } catch (err) { next(err); } });
router.post('/', async (req, res, next) => { try { const { name, objective, status = 'PAUSED', daily_budget, lifetime_budget, start_time, stop_time, special_ad_categories = [] } = req.body; if (!name || !objective) return res.status(400).json({ error: 'name y objective son obligatorios.' }); const { data } = await meta.post('/' + aid() + '/campaigns', { name, objective, status, special_ad_categories, ...(daily_budget && { daily_budget }), ...(lifetime_budget && { lifetime_budget }), ...(start_time && { start_time }), ...(stop_time && { stop_time }) }); res.status(201).json(data); } catch (err) { next(err); } });
router.patch('/:id', async (req, res, next) => { try { const { data } = await meta.post('/' + req.params.id, req.body); res.json(data); } catch (err) { next(err); } });
router.delete('/:id', async (req, res, next) => { try { const { data } = await meta.delete('/' + req.params.id); res.json(data); } catch (err) { next(err); } });
module.exports = router;"

Set-Content -Path "src\routes\ads.js" -Encoding UTF8 -Value "const { Router } = require('express');
const meta = require('../meta');
const router = Router();
const aid = () => process.env.META_AD_ACCOUNT_ID;
router.get('/adsets', async (req, res, next) => { try { const { data } = await meta.get('/' + aid() + '/adsets', { params: { fields: 'id,name,status,campaign_id,daily_budget,targeting,optimization_goal,billing_event', limit: 25 } }); res.json(data); } catch (err) { next(err); } });
router.post('/adsets', async (req, res, next) => { try { const { name, campaign_id, billing_event, optimization_goal, targeting, status = 'PAUSED', daily_budget } = req.body; if (!name || !campaign_id || !billing_event || !optimization_goal || !targeting) return res.status(400).json({ error: 'Faltan campos obligatorios.' }); const { data } = await meta.post('/' + aid() + '/adsets', { name, campaign_id, billing_event, optimization_goal, targeting, status, ...(daily_budget && { daily_budget }) }); res.status(201).json(data); } catch (err) { next(err); } });
router.get('/', async (req, res, next) => { try { const { data } = await meta.get('/' + aid() + '/ads', { params: { fields: 'id,name,status,adset_id,campaign_id,creative,created_time', limit: 25 } }); res.json(data); } catch (err) { next(err); } });
router.post('/', async (req, res, next) => { try { const { name, adset_id, creative, status = 'PAUSED' } = req.body; if (!name || !adset_id || !creative) return res.status(400).json({ error: 'Faltan campos obligatorios.' }); const { data } = await meta.post('/' + aid() + '/ads', { name, adset_id, creative, status }); res.status(201).json(data); } catch (err) { next(err); } });
module.exports = router;"

Set-Content -Path "src\routes\metrics.js" -Encoding UTF8 -Value "const { Router } = require('express');
const meta = require('../meta');
const router = Router();
const aid = () => process.env.META_AD_ACCOUNT_ID;
const FIELDS = 'campaign_name,adset_name,impressions,clicks,spend,reach,ctr,cpc,cpm,actions,date_start,date_stop';
router.get('/account', async (req, res, next) => { try { const { data } = await meta.get('/' + aid() + '/insights', { params: { fields: FIELDS, date_preset: req.query.date_preset || 'last_30d', level: 'account' } }); res.json(data); } catch (err) { next(err); } });
router.get('/campaigns', async (req, res, next) => { try { const { data } = await meta.get('/' + aid() + '/insights', { params: { fields: FIELDS, date_preset: req.query.date_preset || 'last_30d', level: 'campaign' } }); res.json(data); } catch (err) { next(err); } });
router.get('/ads', async (req, res, next) => { try { const { data } = await meta.get('/' + aid() + '/insights', { params: { fields: FIELDS, date_preset: req.query.date_preset || 'last_30d', level: 'ad' } }); res.json(data); } catch (err) { next(err); } });
module.exports = router;"

Set-Content -Path "src\routes\audiences.js" -Encoding UTF8 -Value "const { Router } = require('express');
const meta = require('../meta');
const router = Router();
const aid = () => process.env.META_AD_ACCOUNT_ID;
router.get('/', async (req, res, next) => { try { const { data } = await meta.get('/' + aid() + '/customaudiences', { params: { fields: 'id,name,subtype,approximate_count_lower_bound,description,created_time', limit: 25 } }); res.json(data); } catch (err) { next(err); } });
router.post('/', async (req, res, next) => { try { const { name, subtype, description, rule, retention_days } = req.body; if (!name || !subtype) return res.status(400).json({ error: 'name y subtype son obligatorios.' }); const { data } = await meta.post('/' + aid() + '/customaudiences', { name, subtype, ...(description && { description }), ...(rule && { rule }), ...(retention_days && { retention_days }) }); res.status(201).json(data); } catch (err) { next(err); } });
router.delete('/:id', async (req, res, next) => { try { const { data } = await meta.delete('/' + req.params.id); res.json(data); } catch (err) { next(err); } });
module.exports = router;"

Write-Host "Archivos creados correctamente."