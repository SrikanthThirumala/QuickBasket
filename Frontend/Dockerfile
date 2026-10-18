# 1. Base Image: Use a lightweight Node.js environment
FROM node:18-alpine

# 2. Working Directory
WORKDIR /app

# 3. Install Dependencies
# Copying package files first allows Docker to cache the npm install step
COPY package.json package-lock.json* ./
RUN npm install

# 4. Copy Source Code
COPY . .

# 5. Build the Production Application
RUN npm run build

# 6. Expose Port
EXPOSE 3000

# 7. Start Command: Run Next.js in production mode
CMD ["npm", "start"]

#testing