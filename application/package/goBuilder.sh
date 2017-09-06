wget https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz
tar -xzf go1.4.2.linux-amd64.tar.gz
export GOROOT=~/go
export PATH=$PATH:$GOROOT/bin
export GOBIN=$GOROOT/bin
mkdir ~/golang/
export GOPATH=~/golang/
export PATH=$GOPATH/bin:$PATH
go build