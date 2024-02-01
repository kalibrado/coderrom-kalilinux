
terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

locals {
  username = data.coder_workspace.me.owner
}


variable "socket" {
  type        = string
  description = <<-EOF
  The Unix socket that the Docker daemon listens on and how containers
  communicate with the Docker daemon.

  Either Unix or TCP
  e.g., unix:///var/run/docker.sock

  EOF
  default = "unix:///var/run/docker.sock"
}



provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "coder" {
}

data "coder_workspace" "me" {
}

# Desktop
resource "coder_app" "novnc" {
  agent_id      = coder_agent.dev.id
  display_name  = "noVNC Desktop"
  slug          = "novnc"
  icon          = "https://ppswi.us/noVNC/app/images/icons/novnc-192x192.png"
  url           = "http://localhost:5900"
  subdomain     = true
}

# code-server
resource "coder_app" "code-server" {
  agent_id      = coder_agent.dev.id
  slug          = "cs"
  display_name  = "code-server"
  icon          = "https://cdn.icon-icons.com/icons2/2107/PNG/512/file_type_vscode_icon_130084.png"
  url           = "http://localhost:13337"
  subdomain     = true
}

resource "coder_agent" "dev" {
  arch           = "amd64"
  os             = "linux"
  startup_script = <<EOT
#!/bin/bash
set -euo pipefail

# install and start code-server
curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server --version 4.19.1
/tmp/code-server/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &


EOT
}

resource "docker_image" "main" {
  name = "coder-${data.coder_workspace.me.id}"
  build {
    context = "./build"
    build_args = {
      USER = local.username
    }
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "build/*") : filesha1(f)]))
  }
}

resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}-root"
}


resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = docker_image.main.name
  # Uses lower() to avoid Docker restriction on container names.
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}"
  # Hostname makes the shell more user friendly: coder@my-workspace:~$
  hostname = lower(data.coder_workspace.me.name)
  dns      = ["1.1.1.1"]
  # Use the docker gateway if the access URL is 127.0.0.1 
  command = ["sh", "-c", replace(coder_agent.dev.init_script, "127.0.0.1", "host.docker.internal")]
  env     = ["CODER_AGENT_TOKEN=${coder_agent.dev.token}"]
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  volumes {
    container_path = "/home/coder/"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }
}
