FROM codercom/code-server:latest

# Apply VS Code settings
COPY settings.json .local/share/code-server/User/settings.json
COPY product.json /home/coder/product.json

USER coder

# Use bash shell
ENV SHELL=/bin/bash

# Ensure it runs on port 80
ENV PORT=80

# Use our custom entrypoint script and our python server
COPY azure-entrypoint.sh /usr/bin/azure-entrypoint.sh
COPY miniRedirectServer.py /home/coder/miniRedirectServer.py

USER root
# Add support for SSHing into the app (https://docs.microsoft.com/en-us/azure/app-service/configure-custom-container?pivots=container-linux#enable-ssh)
RUN sudo apt-get update && apt-get install -y openssh-server \
     && echo "root:Docker!" | chpasswd 
COPY sshd_config /etc/ssh/
EXPOSE 80 2222

# Fix permissions
RUN chown -R coder:coder /home/coder

# Fix SSH bug
RUN mkdir -p /var/run/sshd
RUN mkdir /home/coder/project

# Add OpenVSX Extension Gallery
RUN sudo apt-get install -y jq
RUN jq -s '.[0] * .[1]' /home/coder/product.json /usr/lib/code-server/lib/vscode/product.json > /tmp/product.json
RUN mv /tmp/product.json /usr/lib/code-server/lib/vscode/product.json

ENTRYPOINT ["/usr/bin/azure-entrypoint.sh"]