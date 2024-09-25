# Use an official node image based on Alpine 3.18 as a base
FROM node:18.18.0-alpine as build

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json into the container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application into the container
COPY . .

# Build the React app for production
RUN npm run build

# Use Alpine 3.18 as the web server base
FROM alpine:3.18

# Install Nginx in Alpine
RUN apk add --no-cache nginx

# Copy the built app into the Nginx HTML directory
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

