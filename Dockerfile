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
      default-mysql-client \
      pkg-config \
      libssl-dev \
      libffi-dev \
      libyaml-dev \
      libreadline-dev \
      zlib1g-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set working directory
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

# Install bundler
RUN gem install bundler

# Copy gemfiles
COPY Gemfile ./

# Install gems step by step for debugging
RUN bundle config set --local frozen false
RUN bundle config set --local path /usr/local/bundle
RUN gem install mysql2 -v '0.5.6' --source 'https://rubygems.org/'
RUN bundle install --jobs 1 --retry 3

# Copy application code
COPY . .

# Precompile assets without database
RUN SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production ./bin/rails assets:precompile

# Create entrypoint script first (as root)
COPY bin/docker-entrypoint /rails/bin/docker-entrypoint
RUN chmod +x /rails/bin/docker-entrypoint

# Create non-root user
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails /rails

USER rails:rails

# Expose port
EXPOSE 3000

# Start with entrypoint
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]