const mysql = require('mysql2');
require('dotenv').config();

const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

db.connect(err => {
  if (err) {
    console.error('Помилка підключення до MySQL:', err);
  } else {
    console.log('MySQL успішно підключено до бази uni_announce');
  }
});

module.exports = db;