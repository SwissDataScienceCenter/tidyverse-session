FROM ghcr.io/rocker-org/tidyverse:4.4.2

ENV NB_UID=1000
ENV NB_GID=1000
COPY fix-permissions.sh /usr/local/bin
RUN fix-permissions.sh /usr/local/lib/R
RUN fix-permissions.sh /etc/rstudio/
RUN fix-permissions.sh /etc/services.d/rstudio/
RUN fix-permissions.sh /var/run/
# RUN fix-permissions.sh /var/run/s6/

# The container will be run as a regular user, so certain changes need to be done at image build time
ENV DISABLE_AUTH=true
ENV PASSWORD=renkulab
ENV USER=rstudio
RUN cp /etc/rstudio/disable_auth_rserver.conf /etc/rstudio/rserver.conf \
    && echo "USER=$USER" >>/etc/environment

# Use our alternative init_userconf.sh script, which is renkulab compatible
COPY scripts/init_userconf.sh /rocker_scripts/init_userconf.sh

USER rstudio
