FROM alpine:3.20

# Install Dropbear server and OpenSSH client (needed strictly for the scp binary)
RUN apk add --no-cache dropbear openssh-client

# Copy the initialization entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose the default container port
EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
