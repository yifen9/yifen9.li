SHELL := /bin/bash

preview:
	quarto preview sites/www

build:
	quarto render sites/www

push:
	git add -A
	git commit -m "$${MSG:-update}"
	git push