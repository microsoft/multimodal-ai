FROM ghcr.io/actions/actions-runner:2.322.0
# for latest release, see https://github.com/actions/runner/releases

USER root

# install curl and jq
RUN apt-get update && apt-get install -y curl jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

USER runner

ENTRYPOINT ["./entrypoint.sh"]
