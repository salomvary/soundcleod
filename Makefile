update-readme:
	git show master:README.markdown > README.markdown

run:
	jekyll serve --watch

update-and-push:
	git commit -am 'Update site'
	git push
