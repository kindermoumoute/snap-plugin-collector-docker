FROM golang:latest  
ENV GOPATH=$GOPATH:/app
ENV SNAP_PATH=/go/src/github.com/intelsdi-x/snap/build
RUN apt-get update && \
    apt-get -y install facter && \
    apt-get -y install vim
RUN go get github.com/tools/godep && \
    go get golang.org/x/tools/cmd/goimports && \
    go get golang.org/x/tools/cmd/cover && \
    go get github.com/smartystreets/goconvey
WORKDIR /go/src/github.com/intelsdi-x/
RUN git clone https://github.com/intelsdi-x/gomit.git
WORKDIR /go/src/github.com/intelsdi-x/snap-plugin-collector-docker
ADD ./snap-plugin-collector-docker /go/src/github.com/intelsdi-x/snap-plugin-collector-docker
RUN make
WORKDIR /go/src/github.com/intelsdi-x/snap
ADD ./snap /go/src/github.com/intelsdi-x/snap
RUN scripts/deps.sh
RUN make
