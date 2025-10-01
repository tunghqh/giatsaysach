# Use Ruby 3.2 with Debian bookworm
FROM ruby:3.2-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      default-libmysqlclient-dev \
      git \
      libvips \
      curl \
      default-mysql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set working directory
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

# Install bundler
RUN gem install bundler

# Copy gemfiles
COPY Gemfile ./

# Install gems
RUN bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Precompile assets
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Create non-root user
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails /rails

USER rails:rails

# Expose port
EXPOSE 3000

# Start server
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]