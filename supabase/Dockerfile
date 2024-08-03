# Use an official Deno runtime as a parent image
FROM denoland/deno:alpine-1.34.3

# Set the working directory in the container
WORKDIR /app

# Copy the entire project directory into the container at /app
COPY . .

# Navigate to the directory containing index.ts
WORKDIR /app/functions/lambdas

# Install dependencies (deno cache for index.ts)
RUN deno cache index.ts

# Expose the port the app runs on
EXPOSE 54321

# Run the app when the container launches
CMD ["deno", "run", "--allow-net", "--allow-env", "--allow-read", "index.ts"]
