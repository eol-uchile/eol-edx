# Dockerfile for assets export
ARG BASE_IMAGE
FROM ${BASE_IMAGE} AS base

FROM rclone/rclone:1.75 AS s3

COPY --from=base /openedx/staticfiles /data
