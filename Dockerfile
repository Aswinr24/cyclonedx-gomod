FROM golang:1.16-alpine as build
ARG VERSION=latest
RUN go install \
    -ldflags="-s -w -X github.com/CycloneDX/cyclonedx-gomod/internal/version.Version=${VERSION}" \
    github.com/CycloneDX/cyclonedx-gomod@${VERSION}

FROM golang:1.16-alpine
COPY --from=build /go/bin/cyclonedx-gomod /usr/local/bin/
USER 1000
ENTRYPOINT ["cyclonedx-gomod"]
CMD ["-h"]