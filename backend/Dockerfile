FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --production

COPY . .

# PORT is injected by Railway at runtime via environment variable.
# This EXPOSE value matches Railway's default (8080) for documentation only —
# the actual port the app listens on is always process.env.PORT.
EXPOSE 8080

CMD ["node", "src/server.js"]
