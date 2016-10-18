PACKAGE_NAME=vigil
VENV_DIR=virtualenv
TARGET_CV=3.1.0
PIP=$(VENV_DIR)/bin/pip
PYTHON=$(VENV_DIR)/bin/python

$(TARGET_CV).tar.gz :
	wget https://github.com/opencv/opencv/archive/$(TARGET_CV).tar.gz


venv:
	pyvenv $(VENV_DIR)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

clean:
	rm -fr $(VENV_DIR)
	find $(PACKAGE_NAME) -iname "*pyc" -delete
