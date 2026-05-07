const { Router } = require('express');
const meta = require('../meta');
const router = Router();
const aid = () => process.env.META_AD_ACCOUNT_ID;
router.get('/', async (req, res, next) => { try { const { data } = await meta.get('/' + aid() + '/customaudiences', { params: { fields: 'id,name,subtype,approximate_count_lower_bound,description,created_time', limit: 25 } }); res.json(data); } catch (err) { next(err); } });
router.post('/', async (req, res, next) => { try { const { name, subtype, description, rule, retention_days } = req.body; if (!name || !subtype) return res.status(400).json({ error: 'name y subtype son obligatorios.' }); const { data } = await meta.post('/' + aid() + '/customaudiences', { name, subtype, ...(description && { description }), ...(rule && { rule }), ...(retention_days && { retention_days }) }); res.status(201).json(data); } catch (err) { next(err); } });
router.delete('/:id', async (req, res, next) => { try { const { data } = await meta.delete('/' + req.params.id); res.json(data); } catch (err) { next(err); } });
module.exports = router;
