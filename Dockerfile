FROM eoluchile/edx-platform:92103d05a649b664acce7658b4fc66bce8202af0

# Install private requirements: this is useful for installing custom xblocks.
# In particular, to install xblocks from a private repository, clone the
# repositories to ./requirements on the host and add `-e ./myxblock/` to
# ./requirements/private.txt.
COPY ./requirements/ /openedx/requirements
RUN touch /openedx/requirements/private.txt \
    && pip install --src ../venv/src -r /openedx/requirements/private.txt

# Copy themes
COPY ./themes/ /openedx/themes/
RUN openedx-assets themes \
    && openedx-assets collect --settings=prod.assets
