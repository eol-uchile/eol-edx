# Dockerfile for static assets export
ARG BASE_IMAGE
FROM ${BASE_IMAGE} AS base

FROM rclone/rclone:1.56.0 AS s3

COPY --from=base /openedx/staticfiles /data
