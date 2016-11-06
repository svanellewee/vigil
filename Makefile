PACKAGE_NAME=vigil
DEP_DIR=./depdir
VENV_DIR=./virtualenv
SRC_DIR=./src
BUILD_DIR=./opencv-install
TARGET_CV=3.1.0
PIP=$(VENV_DIR)/bin/pip
PYTHON=$(VENV_DIR)/bin/python


OPENCV_TAR=$(DEP_DIR)/opencv-$(TARGET_CV).tar.gz
OPENCV_CONTRIB_TAR=$(DEP_DIR)/opencv_contrib-$(TARGET_CV).tar.gz

OPENCV_SRC=$(SRC_DIR)/opencv-$(TARGET_CV)
OPENCV_CONTRIB_SRC=$(SRC_DIR)/opencv_contrib-$(TARGET_CV)

.PHONY:
	venv clean deps clean-opencv opencv dirs

opencv-tar: $(OPENCV_TAR)
$(OPENCV_TAR):
	wget https://github.com/opencv/opencv/archive/$(TARGET_CV).tar.gz -O $@

opencv-src: $(OPENCV_SRC)
$(OPENCV_SRC):
	tar -xzvf $(OPENCV_TAR) -C $(SRC_DIR)

opencv-contrib-src: $(OPENCV_CONTRIB_SRC)
$(OPENCV_CONTRIB_SRC):
	tar -xzvf $(OPENCV_CONTRIB_TAR) -C $(SRC_DIR)

opencv-contrib-tar: $(OPENCV_CONTRIB_TAR)
$(OPENCV_CONTRIB_TAR):
	wget https://github.com/opencv/opencv_contrib/archive/$(TARGET_CV).tar.gz -O  $@


$(VENV_DIR): 
	pyvenv $@
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

$(SRC_DIR):
	mkdir -p $@

$(INSTALL_DIR):
	mkdir -p $@

$(BUILD_DIR):
	mkdir -p $@

$(DEP_DIR):
	mkdir -p $@

opencv-build2:
	source $(VENV_DIR)/bin/activate && \
	python --version

opencv-build:
	source $(VENV_DIR)/bin/activate && \
	cd $(OPENCV_SRC) && \
	mkdir -p build && \
	cd build && \
	cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=$(realpath $(BUILD_DIR)) \
	-D PYTHON3_NUMPY_INCLUDE_DIRS=$(realpath $(VENV_DIR)/lib/python3.5/site-packages/numpy/core/include) \
	-D BUILD_opencv_python3=ON \
	-D INSTALL_C_EXAMPLES=OFF \
	-D INSTALL_PYTHON_EXAMPLES=ON \
	-D OPENCV_EXTRA_MODULES_PATH=$(realpath $(OPENCV_CONTRIB_SRC)/modules) \
	-D BUILD_EXAMPLES=ON ..  && \
	make -j4 -C . && \
	make install

so-copy:
	cp $(realpath $(OPENCV_SRC)/build/lib/cv2.so) $(realpath $(VENV_DIR)/lib/python3.5/site-packages/)
	cp $(realpath $(OPENCV_SRC)/build/lib/python3/cv2.cpython-35m-darwin.so) $(realpath $(VENV_DIR)/lib/python3.5/site-packages/)

dirs: $(DEP_DIR) $(VENV_DIR)

deps: dirs opencv-tar opencv-contrib-tar

clean:
	rm -fr $(VENV_DIR)
	find $(PACKAGE_NAME) -iname "*pyc" -delete

clean-opencv:
	rm -fr $(OPENCV_TAR)
