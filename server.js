require('dotenv').config();
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
app.listen(PORT, () => console.log('Servidor corriendo en http://localhost:' + PORT));
