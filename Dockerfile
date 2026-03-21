# ---------- builder ----------
FROM debian:12.13-slim AS builder

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

SHELL ["/bin/bash", "-lc"]

WORKDIR /workspace

# isolate dependency layer
COPY --chown=nixuser:nixuser flake.nix flake.lock ./

RUN . $HOME/.nix-profile/etc/profile.d/nix.sh \
 && nix develop --command true

# ---------- runtime ----------
FROM debian:12.13-slim

RUN apt-get update && apt-get install -y \
    ca-certificates bash \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash nixuser

COPY --from=builder /nix /nix
COPY --from=builder /home/nixuser /home/nixuser

USER nixuser
ENV HOME=/home/nixuser
ENV PATH="$HOME/.nix-profile/bin:$PATH"

WORKDIR /workspace

COPY --chown=nixuser:nixuser . .

SHELL ["/bin/bash", "-lc"]

CMD ["bash"]
