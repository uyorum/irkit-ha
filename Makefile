.PHONY: all

image:
	docker build -t uyorum/rpi-irkit-ha -f Dockerfile-rpi .

push:
	docker push uyorum/rpi-irkit-ha
