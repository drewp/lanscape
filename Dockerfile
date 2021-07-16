FROM bang5:5000/base_x86

WORKDIR /opt

COPY requirements.txt ./
RUN pip3 install --index-url https://projects.bigasterisk.com/ --extra-index-url https://pypi.org/simple -r requirements.txt

COPY *.py ./
COPY index.html ./
COPY *.n3 ./

EXPOSE 8001

CMD [ "python3", "lanscape.py" ]
