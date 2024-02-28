# Use the official Ruby image with the desired version
FROM ruby:3.1.2

# Set the working directory inside the container
WORKDIR /app

# Install Node.js and npm
RUN apt-get update && apt-get install -y nodejs npm

# Copy the Gemfile and Gemfile.lock to the container
COPY Gemfile Gemfile.lock ./

# Install dependencies
RUN gem install bundler
RUN bundle install

# Copy the rest of the application code to the container
COPY . .

# Expose the port that your Rails app will run on
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
