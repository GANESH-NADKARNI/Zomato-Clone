# Use an official Node.js image as the base (current LTS)
FROM node:22-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first (leverage Docker cache)
COPY package*.json ./

# Install ALL dependencies (build tooling like vite lives in devDependencies)
RUN npm ci

# Copy the rest of the application source code
COPY . .

# Build the app
RUN npm run build

# ---- Production Stage ----
FROM node:22-alpine

WORKDIR /app

# Only bring over what's needed to serve the built output
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/build ./build
COPY --from=builder /app/vite.config.js ./vite.config.js

EXPOSE 3000

CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0"]

## Dockerfile