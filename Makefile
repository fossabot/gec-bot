IMG ?= ghcr.io/gender-equality-community/gec-bot
TAG ?= latest
LOGLVL ?= INFO
COSIGN_SECRET ?= cosign.key

default: app

app: *.go go.mod go.sum config.gen.go
	go build -o $@ -ldflags="-s -w -linkmode=external -X main.LogLevel=$(LOGLVL)" -buildmode=pie -trimpath
	upx $@

config.gen.go: config.toml gen/main.go
	go run gen/main.go -f $< > $@

.PHONY: docker-build docker-push
docker-build:
	docker build --label "tag=$(TAG)" --label "bom=https://github.com/gender-equality-community/gec-bot/releases/download/$(TAG)/bom.json" --build-arg logLevel=$(LOGLVL) -t $(IMG):$(TAG) .

docker-push:
	docker push $(IMG):$(TAG)

.image:
	echo $(IMG):$(TAG) > $@
