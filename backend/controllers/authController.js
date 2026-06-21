const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.register = (req, res) => {
  const { name, email, password, role, group, course } = req.body;

  if (!name || !email || !password || !role) {
    return res.status(400).json({ message: "Заповніть всі обов'язкові поля" });
  }

  bcrypt.hash(password, 10, (err, hash) => {
    if (err) return res.status(500).json({ error: err.message });

    const sql = `INSERT INTO users (name, email, password_hash, role, \`group\`, course) 
                 VALUES (?, ?, ?, ?, ?, ?)`;

    db.query(sql, [name, email, hash, role, group || null, course || null], (err, result) => {
      if (err) {
        if (err.code === 'ER_DUP_ENTRY') {
          return res.status(400).json({ message: "Користувач з таким email вже існує" });
        }
        return res.status(500).json({ error: err.message });
      }
      res.status(201).json({ message: "Реєстрація успішна!" });
    });
  });
};

exports.login = (req, res) => {
  const { email, password } = req.body;

  db.query(`SELECT * FROM users WHERE email = ?`, [email], (err, results) => {
    if (err || results.length === 0) {
      return res.status(400).json({ message: "Невірний email або пароль" });
    }

    const user = results[0];

    bcrypt.compare(password, user.password_hash, (err, isMatch) => {
      if (!isMatch) {
        return res.status(400).json({ message: "Невірний email або пароль" });
      }

      const token = jwt.sign(
        { id: user.id, role: user.role, name: user.name },
        process.env.JWT_SECRET,
        { expiresIn: '24h' }
      );

      res.json({
        token,
        user: {
          id: user.id,
          name: user.name,
          role: user.role,
          group: user.group,
          course: user.course
        }
      });
    });
  });
};