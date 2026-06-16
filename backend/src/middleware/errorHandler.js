const errorHandler = (err, req, res, next) => {
  console.error('Error Details:', {
    message: err.message,
    code: err.code,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });

  if (err.statusCode) {
    return res.status(err.statusCode).json({ 
      success: false,
      error: err.message 
    });
  }

  // MySQL specific errors
  if (err.code) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ 
        success: false,
        error: 'This email or phone number is already registered' 
      });
    }
    if (err.code === 'ER_NO_REFERENCED_ROW_2') {
      return res.status(400).json({ 
        success: false,
        error: 'Invalid reference' 
      });
    }
    if (err.code === 'ECONNREFUSED') {
      return res.status(503).json({ 
        success: false,
        error: 'Database connection failed. Please try again later.' 
      });
    }
    if (err.code === 'ER_BAD_DB_ERROR') {
      return res.status(503).json({ 
        success: false,
        error: 'Database not found. Please contact administrator.' 
      });
    }
    if (err.code === 'ER_NO_SUCH_TABLE') {
      return res.status(503).json({ 
        success: false,
        error: 'Database table not found. Please run migrations.' 
      });
    }
  }

  // Network and timeout errors
  if (err.name === 'TimeoutError') {
    return res.status(408).json({ 
      success: false,
      error: 'Request timeout. Please try again.' 
    });
  }

  res.status(500).json({ 
    success: false,
    error: 'Internal Server Error',
    details: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
};

module.exports = errorHandler;
