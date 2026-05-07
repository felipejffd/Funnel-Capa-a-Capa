const { Router } = require('express');
const meta = require('../meta');
const router = Router();
const aid = () => process.env.META_AD_ACCOUNT_ID;
const FIELDS = 'campaign_name,adset_name,impressions,clicks,spend,reach,ctr,cpc,cpm,actions,date_start,date_stop';
router.get('/account', async (req, res, next) => { try { const { data } = await meta.get('/' + aid() + '/insights', { params: { fields: FIELDS, date_preset: req.query.date_preset || 'last_30d', level: 'account' } }); res.json(data); } catch (err) { next(err); } });
router.get('/campaigns', async (req, res, next) => { try { const { data } = await meta.get('/' + aid() + '/insights', { params: { fields: FIELDS, date_preset: req.query.date_preset || 'last_30d', level: 'campaign' } }); res.json(data); } catch (err) { next(err); } });
router.get('/ads', async (req, res, next) => { try { const { data } = await meta.get('/' + aid() + '/insights', { params: { fields: FIELDS, date_preset: req.query.date_preset || 'last_30d', level: 'ad' } }); res.json(data); } catch (err) { next(err); } });
module.exports = router;
