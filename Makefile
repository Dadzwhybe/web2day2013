all: build

build: site
	./site build

site: site.hs LinkedCompilers.hs RouteFactories.hs Utils.hs
	ghc --make site.hs
	./site clean

preview: site
	./site preview

clean: site
	./site clean

mrproper: clean
	rm site
	rm *.hi
	rm *.o

publish: build
	git remote add clever git+ssh://git@push.clever-cloud.com/app_afb08f99-09ec-467b-a7db-c99887ad3d94.git || true
	git stash save
	./ensure_publish_branch.sh
	git checkout publish || true
	find . -maxdepth 1 ! -name '.' ! -name '.git*' ! -name '_site' -exec rm -rf {} +
	find _site -maxdepth 1 -exec mv {} . \;
	rmdir _site
	git add -A && git commit -m "Publish" || true
	git push -f clever publish:master
	git checkout master
	git clean -fdx
	git stash pop || true
