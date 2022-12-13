.PHONY: build

IMAGENAME = mikinglang/workshop
VERSION = 2022-1

BUILD_LOGDIR=./_logs

VALIDATE_IMAGE_SCRIPT=./scripts/validate_image.py
VALIDATE_ARCH_SCRIPT="./scripts/validate_architecture.py"

build:
	@echo -e "\033[1;31mSpecify the platform you are building for with \033[1;37mmake build/<arch>\033[0m"

build/%:
	$(eval UID := $(shell if [[ -z "$$SUDO_UID" ]]; then id -u; else echo "$$SUDO_UID"; fi))
	$(eval GID := $(shell if [[ -z "$$SUDO_GID" ]]; then id -g; else echo "$$SUDO_GID"; fi))
	$(eval LOGFILE := $(BUILD_LOGDIR)/$(shell date "+workshop_%Y-%m-%d_%H.%M.%S.log"))

	$(VALIDATE_ARCH_SCRIPT) $*

	mkdir -p $(BUILD_LOGDIR)
	touch $(LOGFILE)
	chown $(UID):$(GID) $(BUILD_LOGDIR) $(LOGFILE)

	docker build --tag $(IMAGENAME):$(VERSION)-$* \
	             --force-rm \
	             --progress=plain \
	             --build-arg "TARGETPLATFORM=linux/$*" \
	             --file Dockerfile \
	             . 2>&1 | tee -a $(LOGFILE)
	$(VALIDATE_IMAGE_SCRIPT) --arch=$* $(IMAGENAME):$(VERSION)-$*

push:
	@echo -e "\033[1;31mSpecify the platform you are pushing for with \033[1;37mmake push/<arch>\033[0m"

push/%:
	$(VALIDATE_ARCH_SCRIPT) $*
	docker push $(IMAGENAME):$(VERSION)-$*

push-manifests:
	$(eval AMENDMENTS := $(foreach a,amd64 arm64,--amend $(IMAGENAME):$(VERSION)-$a))
	echo $(AMENDMENTS)

	docker manifest create $(IMAGENAME):$(VERSION) $(AMENDMENTS)
	docker manifest create $(IMAGENAME):latest $(AMENDMENTS)
	docker manifest push $(IMAGENAME):$(VERSION)
	docker manifest push $(IMAGENAME):latest
