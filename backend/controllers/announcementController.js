const db = require('../config/db');
const { io } = require('../server');

exports.createAnnouncement = (req, res) => {
    const { title, description, target_type, target_value, subject } = req.body;
    const author_id = req.user.id;
    const file_url = req.file ? `/uploads/${req.file.filename}` : null;
  
    console.log(" Отримано файл:", req.file ? req.file.originalname : "немає файлу");
    console.log(" Дані оголошення:", { title, target_type, target_value });
  
    if (!title || !description) {
      return res.status(400).json({ message: "Назва та опис обов'язкові" });
    }
  
    const sql = `INSERT INTO announcements 
      (title, description, author_id, target_type, target_value, subject, file_url) 
      VALUES (?, ?, ?, ?, ?, ?, ?)`;
  
    db.query(sql, [title, description, author_id, target_type, target_value, subject, file_url], 
      (err, result) => {
        if (err) {
          console.error(" Помилка збереження в БД:", err);
          return res.status(500).json({ 
            message: "Помилка при збереженні оголошення", 
            error: err.message 
          });
        }
  
        const announcementId = result.insertId;
        if (global.io) {
            global.io.emit('new_announcement', {
              id: announcementId,
              title,
              description,
            });
          }
        
        res.status(201).json({ 
          message: "Оголошення успішно створено!",
          id: announcementId 
        });
      });
  };
exports.getAnnouncements = (req, res) => {
  const { role, course, group } = req.user;

  let sql = `SELECT a.*, u.name as author_name 
             FROM announcements a 
             JOIN users u ON a.author_id = u.id`;

  if (role === 'student') {
    sql += ` WHERE target_type = 'all' 
             OR (target_type = 'course' AND target_value = ?) 
             OR (target_type = 'group' AND target_value = ?)`;
    
    db.query(sql + ` ORDER BY a.created_at DESC`, [course, group], (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    });
  } else {
    db.query(sql + ` ORDER BY a.created_at DESC`, (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    });
  }
};

exports.getAnnouncementById = (req, res) => {
  const { id } = req.params;
  db.query(`SELECT a.*, u.name as author_name 
            FROM announcements a 
            JOIN users u ON a.author_id = u.id 
            WHERE a.id = ?`, [id], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    if (result.length === 0) return res.status(404).json({ message: "Оголошення не знайдено" });
    res.json(result[0]);
  });
};
// Видалення оголошення
exports.deleteAnnouncement = (req, res) => {
    const { id } = req.params;
    const author_id = req.user.id;
  
    console.log(`Спроба видалення оголошення ID: ${id} користувачем: ${author_id}`); 
  
    const sql = `DELETE FROM announcements WHERE id = ? AND author_id = ?`;
  
    db.query(sql, [id, author_id], (err, result) => {
      if (err) {
        console.error("Помилка видалення:", err);
        return res.status(500).json({ error: err.message });
      }
  
      if (result.affectedRows === 0) {
        return res.status(403).json({ message: "Ви можете видаляти тільки свої оголошення" });
      }
  
      res.json({ message: "Оголошення успішно видалено" });
    });
  };
  
  // Редагування оголошення
  exports.updateAnnouncement = (req, res) => {
    const { id } = req.params;
    const { title, description, subject, target_type, target_value } = req.body;
    const author_id = req.user.id;
  
    const sql = `UPDATE announcements SET title=?, description=?, subject=?, target_type=?, target_value=? 
                 WHERE id=? AND author_id=?`;
  
    db.query(sql, [title, description, subject, target_type, target_value, id, author_id], (err, result) => {
      if (err) return res.status(500).json({ error: err.message });
      if (result.affectedRows === 0) return res.status(403).json({ message: "Ви можете редагувати тільки свої оголошення" });
      
      res.json({ message: "Оголошення оновлено" });
    });
  };