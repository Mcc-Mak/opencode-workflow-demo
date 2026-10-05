# syntax=docker/dockerfile:1

# Build stage: compile the Vite app to static assets.
FROM node:24-alpine AS build
WORKDIR /app
COPY site/package.json site/package-lock.json ./
RUN npm ci --ignore-scripts
COPY site/ ./
RUN npm run build

# Runtime stage: serve the static build with nginx (non-root).
FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 8080
USER nginx
CMD ["nginx", "-g", "daemon off;"]
