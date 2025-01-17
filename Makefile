PATHNAME=$(shell pwd)
BASENAME=$(shell basename $(PATHNAME))

TAG=`cat VERSION.txt`

all:
	make -f Makefile html


stats:
	pep8 --statistics --filename *.py */*.py */*/*.py */*/*/*.py */*/*/*/*.py */*/*/*/*/*.py

autopep8:
	autopep8 -i */*.py
	autopep8 -i */*/*.py
	autopep8 -i */*/*/*.py
	autopep8 -i */*/*/*/*.py
	autopep8 -i */*/*/*/*/*.py
	autopep8 -i */*/*/*/*/*/*.py

######################################################################
# GIT INTERFACES
######################################################################
push:
	make -f Makefile clean
	git commit -a 
	git push

pull:
	git pull 

gregor:
	git config --global user.name "Gregor von Laszewski"
	git config --global user.email laszewski@gmail.com

git-ssh:
	git remote set-url origin git@github.com:cloudmesh/$(BASENAME).git


######################################################################
# INSTALLATION
######################################################################
req:
	pip install -r requirements.txt

dist:
	make -f Makefile pip

sdist: clean
	#make -f Makefile clean
	python setup.py sdist --format=bztar,zip


force:
	make -f Makefile nova
	make -f Makefile pip
	pip install -U dist/*.tar.gz

install:
	pip install dist/*.tar.gz

######################################################################
# PYPI
######################################################################

upload:
	make -f Makefile pip
#	python setup.py register
	python setup.py sdist upload

pip-register:
	python setup.py register

######################################################################
# QC
######################################################################

qc-install:
	pip install pep8
	pip install pylint
	pip install pyflakes

qc:
	pep8 ./cloudmesh/virtual/cluster/
	pylint ./cloudmesh/virtual/cluster/ | less
	pyflakes ./cloudmesh/virtual/cluster/

# #####################################################################
# CLEAN
# #####################################################################


clean:
	rm -rf *.egg
	find . -name "*~" -exec rm {} \;  
	find . -name "*.pyc" -exec rm {} \;  
	rm -rf build doc/build dist *.egg-info *~ #*
	cd doc; make clean
	rm -rf *.egg-info

uninstall:
	yes | pip uninstall cloudmesh

#############################################################################
# SPHINX DOC
###############################################################################

html: sphinx
	echo done

sphinx:
	cd doc; make html
	open doc/build/html/index.html

#############################################################################
# PUBLISH GIT HUB PAGES
###############################################################################

gh-pages:
	git checkout gh-pages
	make pages

######################################################################
# TAGGING
######################################################################


tag:
	make clean
	python bin/util/next_tag.py
	git tag $(TAG)
	echo $(TAG) > VERSION.txt
	git add .
	git commit -m "adding version $(TAG)"
	git push


######################################################################
# ONLY RUN ON GH-PAGES
######################################################################

PROJECT=`basename $(PWD)`
DIR=/tmp/$(PROJECT)
DOC=$(DIR)/doc

pages: ghphtml ghpgit
	echo done

ghphtml:
	cd /tmp
	rm -rf $(DIR)
	cd /tmp; git clone git://github.com/cloudmesh/$(PROJECT).git
	cp $(DIR)/Makefile .
	cd $(DOC); ls; make html
	rm -fr _static
	rm -fr _source
	rm -fr *.html
	cp -r $(DOC)/build/html/* .

ghpgit:
	git add . _sources _static   
	git commit -a -m "updating the github pages"
	git push
	git checkout master

