require('dotenv').config();

const express = require('express');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');
const rateLimit = require('express-rate-limit');
const morgan = require('morgan');
const { Pool } = require('pg');

const app = express();

const PORT = Number(process.env.PORT || 4100);

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  max: 10,
  idleTimeoutMillis: 30000,
});

app.use(helmet());
app.use(express.json({ limit: '1mb' }));
app.use(cookieParser());
app.use(morgan('combined'));

app.use('/api/', rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
}));

app.get('/api/health', (req, res) => {
  res.json({
    ok: true,
    service: 'decroche-ton-oral-backend',
    time: new Date().toISOString(),
  });
});

app.get('/api/db-check', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT current_database() AS database, current_user AS user, NOW() AS time'
    );

    res.json({
      ok: true,
      db: result.rows[0],
    });
  } catch (error) {
    console.error('DB_CHECK_ERROR:', error);
    res.status(500).json({
      ok: false,
      error: 'Database connection failed',
    });
  }
});

app.use('/api/', (req, res) => {
  res.status(404).json({
    ok: false,
    error: 'API route not found',
  });
});

app.listen(PORT, '127.0.0.1', () => {
  console.log(`Décroche ton oral backend running on http://127.0.0.1:${PORT}`);
});
