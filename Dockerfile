FROM golang:1.21.6-alpine3.18@sha256:3bd447580bc0df66bada3d8e38f37ca85faf66d6a0e37f0ccba287eaf5962757 AS build
WORKDIR /usr/src/app
RUN apk --no-cache add git make
COPY ./go.mod ./go.sum ./
RUN go mod download
COPY . .
RUN make install

FROM golang:1.21.6-alpine3.18@sha256:3bd447580bc0df66bada3d8e38f37ca85faf66d6a0e37f0ccba287eaf5962757
# When running as non-root user, GOCACHE must be set to a directory
# that is writable by that user. It will otherwise default to /.cache/go-build,
# which is owned by root.
# https://github.com/golang/go/issues/26280#issuecomment-445294378
ENV GOCACHE=/tmp/go-build
COPY --from=build /go/bin/cyclonedx-gomod /usr/local/bin/
USER 1000
ENTRYPOINT ["cyclonedx-gomod"]
CMD ["-h"]
