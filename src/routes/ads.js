const { Router } = require('express');
const meta = require('../meta');
const router = Router();
const aid = () => process.env.META_AD_ACCOUNT_ID;
router.get('/adsets', async (req, res, next) => { try { const { data } = await meta.get('/' + aid() + '/adsets', { params: { fields: 'id,name,status,campaign_id,daily_budget,targeting,optimization_goal,billing_event', limit: 25 } }); res.json(data); } catch (err) { next(err); } });
router.post('/adsets', async (req, res, next) => { try { const { name, campaign_id, billing_event, optimization_goal, targeting, status = 'PAUSED', daily_budget } = req.body; if (!name || !campaign_id || !billing_event || !optimization_goal || !targeting) return res.status(400).json({ error: 'Faltan campos obligatorios.' }); const { data } = await meta.post('/' + aid() + '/adsets', { name, campaign_id, billing_event, optimization_goal, targeting, status, ...(daily_budget && { daily_budget }) }); res.status(201).json(data); } catch (err) { next(err); } });
router.get('/', async (req, res, next) => { try { const { data } = await meta.get('/' + aid() + '/ads', { params: { fields: 'id,name,status,adset_id,campaign_id,creative,created_time', limit: 25 } }); res.json(data); } catch (err) { next(err); } });
router.post('/', async (req, res, next) => { try { const { name, adset_id, creative, status = 'PAUSED' } = req.body; if (!name || !adset_id || !creative) return res.status(400).json({ error: 'Faltan campos obligatorios.' }); const { data } = await meta.post('/' + aid() + '/ads', { name, adset_id, creative, status }); res.status(201).json(data); } catch (err) { next(err); } });
module.exports = router;
