FROM ubuntu:16.04

# general
RUN apt-get update && apt-get install -y build-essential cmake \
    wget git unzip \
    yasm pkg-config software-properties-common python3-software-properties

# get python 3.6.3
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update && \
    apt-get install -y python3.6 python3.6-dev python3.6-venv

# pip3 stuff
RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python3.6 get-pip.py && \
    python3.6 -m pip install pip --upgrade

RUN rm -f /usr/bin/python && ln -s /usr/bin/python3.6 /usr/bin/python
RUN rm -f /usr/bin/python3 && ln -s /usr/bin/python3.6 /usr/bin/python3
RUN rm -f /usr/local/bin/pip && ln -s /usr/local/bin/pip3.6 /usr/local/bin/pip
RUN rm -f /usr/local/bin/pip3 && ln -s /usr/local/bin/pip3.6 /usr/local/bin/pip3

WORKDIR /

RUN mkdir /home/workspace
WORKDIR /home/workspace
COPY . /home/workspace

# install python dependencies
RUN apt-get install -y gcc python3.6-dev
RUN pip3 install spacy
RUN pip3 install sklearn
RUN pip3 install pandas
RUN pip3 install Flask
RUN pip3 install gunicorn
RUN pip3 install requests
RUN pip3 install numpy
RUN pip3 install scipy
RUN pip3 install python-dotenv

# install spacy Spanish data
RUN python3.6 -m spacy download es

# Run chatbot
EXPOSE 4000
ENV PYTHONIOENCODING=utf8
ENV LANG='en_US.UTF-8'
ENV VERIFY_TOKEN='mememonster'
ENV PAGE_ACCESS_TOKEN='EAAcO83vdtXABAMbxcdRM3tUIiuyQVr7uYRuw9TYOZB8K2cCaUWZA2FMebjTJ4hBZCkhMixPxqgTKNmKSJYnCM6ad1Y49l92inX7EmH9r6PbDnM0u3cUpdoxN5XsXbC3ZAMbDrlGj6X89YwWHHbKg1vIvndoMmUcjdEijuuc00z8lqqptpGvE'

# Get started message
CMD curl \
	-X POST	\
	-H "Content-Type: application/json" \
	-d '{"get_started":{"payload": "GET_STARTED_PAYLOAD"}}' \
	"https://graph.facebook.com/v2.6/me/messenger_profile?access_token="$PAGE_ACCESS_TOKEN

# Greeting text
CMD curl \
	-X POST \
	-H "Content-Type: application/json" \
	-d '{"greeting":[{"locale":"default","text":"3, 2, 1... MEME IT RIP!"}, {"locale":"en_US","text":"Help scientists understand today´s world through memes!"}]' \
	"https://graph.facebook.com/v2.6/me/messenger_profile?access_token="$PAGE_ACCESS_TOKEN

CMD python3.6 bot.py
# CMD gunicorn \
# 	-w 2 \
# 	-t 2 \
# 	-b 0.0.0.0:4000 \
# 	--timeout 30 \
# 	bot:app
