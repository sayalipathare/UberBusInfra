resource "null_resource" "remote_exec_from_github" {

  connection {
    host        = "54.157.219.30"
    type        = "ssh"
    user        = "ubuntu"
    agent       = "true"
    private_key = file("/Users/sayalipathare/Documents/DevOps/UberBusModified/Infra/UberBusInfra/uberkey")
  }

  provisioner "file" {
    source      = "/Users/sayalipathare/Documents/DevOps/UberBusModified/Infra/UberBusInfra/resources/app"
    destination = "/home/ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /home/ubuntu/fe",
      "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash",
      ". ~/.nvm/nvm.sh",
      "nvm install node",
      "git clone https://github.com/sayalipathare/UberBusfe /home/ubuntu/fe",
      "cd fe",
      "npm install",
      "npm run build",
      "cd ~",
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo rm /etc/nginx/sites-enabled/default",
      "sudo cp /home/ubuntu/app/uber.nginx /etc/nginx/sites-available/",
      "sudo chmod 777 /etc/nginx/sites-available/uber.nginx",
      "sudo ln -s /etc/nginx/sites-available/uber.nginx /etc/nginx/sites-enabled/uber.nginx",
      "sudo systemctl reload nginx",

      "sudo cp /home/ubuntu/app/uberbe.service /etc/systemd/system/",
      "mkdir /home/ubuntu/be",
      "git clone https://github.com/sayalipathare/UberBusBe /home/ubuntu/be",
      "sudo cp /home/ubuntu/app/wsgi.py /home/ubuntu/be/",
      "cd be",
      "sudo apt update",
      "sudo apt install python3-pip python3-dev build-essential libssl-dev libffi-dev python3-setuptools -y",
      "sudo apt install python3-venv -y",
      "python3 -m venv .venv",
      "source .venv/bin/activate",
      "pip3 install gunicorn",
      "pip3 install flask",
      "pip3 install python-dotenv",
      "pip3 install flask-cors",
      "pip3 install flask-api",
      "pip3 install pymongo",
      "pip3 install requests",
      "pip3 install python-dateutil --upgrade",
      "pip3 install pytz",
      "pip3 install dnspython",
      "sudo systemctl daemon-reload",
      "sudo systemctl start uberbe",
    ]
  }
}
