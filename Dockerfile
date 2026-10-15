# Перенос с App Platform (build: npm install, run: node server.js) на дроплет 178.62.221.69.
FROM node:22
WORKDIR /app
COPY . .
RUN npm install
ENV PORT=8080
EXPOSE 8080
CMD ["node", "server.js"]
