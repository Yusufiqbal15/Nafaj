const jwt = require('jsonwebtoken');

const optionalAuth = (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (token) {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = decoded;
    }
  } catch (_) {
    // No valid token — continue as anonymous
  }
  next();
};

module.exports = optionalAuth;
