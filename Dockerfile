FROM debian:12.13-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ca-certificates curl xz-utils git bash \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash nixuser

USER nixuser
ENV HOME=/home/nixuser
ENV PATH="$HOME/.nix-profile/bin:$PATH"

RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

RUN mkdir -p $HOME/.config/nix \
 && echo "experimental-features = nix-command flakes" > $HOME/.config/nix/nix.conf

WORKDIR /workspace

COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
