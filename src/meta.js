const axios = require('axios');
const metaClient = axios.create({ baseURL: 'https://graph.facebook.com/' + (process.env.META_API_VERSION || 'v21.0'), timeout: 30000 });
metaClient.interceptors.request.use((config) => { config.params = { ...config.params, access_token: process.env.META_ACCESS_TOKEN }; return config; });
metaClient.interceptors.response.use((res) => res, (err) => { const e = err.response?.data?.error; if (e) { const error = new Error(e.message); error.code = e.code; error.type = e.type; error.status = err.response.status; return Promise.reject(error); } return Promise.reject(err); });
module.exports = metaClient;
