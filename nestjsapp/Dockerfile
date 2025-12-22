# Step 1: Use a Node.js base image
FROM node:20-alpine

# Step 2: Set the working directory inside the container
WORKDIR /app

# Step 3: Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Step 4: Install project dependencies
RUN npm install

# Step 5: Copy the rest of the application code to the working directory
COPY . .

# Step 6: Build the NestJS application
RUN npm run build

# Step 7: Expose the port the app will run on
EXPOSE 3000

# Step 8: Define the command to run the app
CMD ["npm", "run", "start:prod"]