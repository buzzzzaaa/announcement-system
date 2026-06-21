const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, { 
  cors: { origin: "*" } 
});

// === ВАЖЛИВО: Ці два рядки повинні бути на самому початку ===
app.use(cors());
app.use(express.json());           // ← Це було пропущено або не спрацювало
app.use(express.urlencoded({ extended: true }));

app.use('/uploads', express.static('uploads'));

// Routes
app.get('/api/test', (req, res) => {
    res.json({
      status: 'ok'
    });
  });
app.use('/api/auth', require('./routes/auth'));
app.use('/api/announcements', require('./routes/announcement'));

// Socket.IO
io.on('connection', (socket) => {
  console.log('Користувач підключився:', socket.id);

  socket.on('join', (userId) => {
    socket.join(`user_${userId}`);
  });

  socket.on('disconnect', () => {
    console.log('Користувач відключився');
  });
});

const PORT = process.env.PORT || 5001;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Сервер запущено на http://localhost:${PORT}`);
});

global.io = io;