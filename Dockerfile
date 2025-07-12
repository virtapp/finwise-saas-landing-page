# 1. Install dependencies in a builder stage
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./
RUN npm ci

# Copy source and configurations
COPY src /app
# Build the Next.js app
RUN npm run build

# 2. Run in minimal production stage
FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Copy over production node_modules and build output
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.mjs ./next.config.mjs
COPY --from=builder /app/package.json ./package.json

# Expose default Next port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
