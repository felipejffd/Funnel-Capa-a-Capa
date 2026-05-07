const { Router } = require('express');
const meta = require('../meta');
const router = Router();
const aid = () => process.env.META_AD_ACCOUNT_ID;
router.get('/', async (req, res, next) => { try { const { data } = await meta.get('/' + aid() + '/campaigns', { params: { fields: 'id,name,status,objective,daily_budget,lifetime_budget,start_time,stop_time,created_time', limit: req.query.limit || 25 } }); res.json(data); } catch (err) { next(err); } });
router.post('/', async (req, res, next) => { try { const { name, objective, status = 'PAUSED', daily_budget, lifetime_budget, start_time, stop_time, special_ad_categories = [] } = req.body; if (!name || !objective) return res.status(400).json({ error: 'name y objective son obligatorios.' }); const { data } = await meta.post('/' + aid() + '/campaigns', { name, objective, status, special_ad_categories, ...(daily_budget && { daily_budget }), ...(lifetime_budget && { lifetime_budget }), ...(start_time && { start_time }), ...(stop_time && { stop_time }) }); res.status(201).json(data); } catch (err) { next(err); } });
router.patch('/:id', async (req, res, next) => { try { const { data } = await meta.post('/' + req.params.id, req.body); res.json(data); } catch (err) { next(err); } });
router.delete('/:id', async (req, res, next) => { try { const { data } = await meta.delete('/' + req.params.id); res.json(data); } catch (err) { next(err); } });
module.exports = router;
