FROM steamcmd/steamcmd

LABEL maintainer="brenno263@gmail.com"

ENV STEAMAPPID 380870
ENV APP_DIR "/opt/zomboid_app"
ENV DATA_DIR "/opt/zomboid_data"

# install packages
# RUN apt-get update \
# 	&& apt-get install -y --no-install-recommends --no-install-suggests \
# 	&& apt-get clean \
# 	&& rm -rf /var/lib/apt/lists/*

# Download the PZ server app using steam
# Also set entry point permissions
RUN set -x \
	&& mkdir -p "${APP_DIR}" \
	&& mkdir -p "${DATA_DIR}" \
	&& steamcmd \
		+force_install_dir "${APP_DIR}" \
		+login anonymous \
		+app_update "${STEAMAPPID}" \
		+quit

COPY --chown=${USER}:${USER} scripts /opt/zomboid_scripts

EXPOSE 16261-16262/udp

ENTRYPOINT [ "/opt/zomboid_scripts/entry.sh" ]
