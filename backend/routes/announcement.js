const express = require('express');
const router = express.Router();
const multer = require('multer');
const authenticate = require('../middleware/auth');
const announcementController = require('../controllers/announcementController');

// Налаштування Multer для файлів
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  }
});

const upload = multer({ storage: storage });


router.post('/', authenticate, upload.single('file'), announcementController.createAnnouncement);
router.get('/', authenticate, announcementController.getAnnouncements);
router.get('/:id', authenticate, announcementController.getAnnouncementById);
router.put('/:id', authenticate, announcementController.updateAnnouncement);
router.delete('/:id', authenticate, announcementController.deleteAnnouncement);

module.exports = router;