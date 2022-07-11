FROM ubuntu:20.04

RUN apt-get update && apt-get install -y openssh-server

RUN mkdir /var/run/sshd

ARG ROOT_PASSWORD
RUN echo root:${ROOT_PASSWORD} | chpasswd

RUN sed -i 's/#\?PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

# [ADD] for pip
RUN apt-get install -y python3
RUN apt-get install -y python3-pip

# [ADD] For ipynb
RUN pip install --upgrade pip
RUN pip install ipykernel

# [ADD] for vim
RUN apt-get install -y vim

# [ADD] for vscode
RUN apt-get install -y wget gpg
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
RUN install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
RUN sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
RUN rm -f packages.microsoft.gpg
RUN apt install -y apt-transport-https
RUN apt update -y
RUN apt install -y code

# [ADD] for login root
RUN echo "password\npassword\n" | passwd root

# ----- [BASE] -----

# [ADD] For BERT
RUN pip install transformers==4.18.0 fugashi==1.1.0 ipadic==1.0.0 pytorch-lightning==1.6.1
RUN apt-get update -y
RUN apt-get install -y libmecab2