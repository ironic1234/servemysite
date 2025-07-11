# Stage 1: Build statically with musl
FROM rust:latest as builder
WORKDIR /app
COPY . .

# Add musl target and build
RUN rustup target add x86_64-unknown-linux-musl && \
    cargo build --release --target=x86_64-unknown-linux-musl

# Stage 2: Use Alpine to run the static binary
FROM alpine:latest
WORKDIR /app

# Copy only the static binary
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/ronfire /ronfire/app

# Copy files to serve
COPY ./web .

# Create socket directory
RUN mkdir -p /app/socket
VOLUME ["/app/socket"]

# Run the binary
CMD ["/ronfire/app", "socket/website.sock"]
