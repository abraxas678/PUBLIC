MYSUDO:='sudo'
HOME:='/home/abrax'

inst-zsh4h:
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"

inst-kopia:
  curl -s https://kopia.io/signing-key | sudo gpg --dearmor -o /etc/apt/keyrings/kopia-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kopia-keyring.gpg] http://packages.kopia.io/apt/ stable main" | sudo tee /etc/apt/sources.list.d/kopia.list
  sudo apt update
  sudo apt install -y kopia kopia-ui

inst-gum:
	# Install Gum
	@bash -c "wget 'https://github.com/charmbracelet/gum/releases/download/v0.14.5/gum_0.14.5_amd64.deb';"
	{{MYSUDO}} apt install -y ./gum_0.14.5_amd64.deb



# ----------------------------
# echothis2:
# Prints a completion message.
# Usage: just echothis2 "Message"

echothis2 message:
	@echo -e "\e[1;36m└─ 󰄬 {{message}} installation completed\e[0m"

# ----------------------------
# isinstalled:
# Checks whether a given command is installed.
# If not, it optionally installs it after confirmation.
# Usage: just isinstalled pkg_name
isinstalled pkg:
	@if ! command -v {{pkg}} >/dev/null 2>&1; then \
		if just confirm-step "Install {{pkg}}"; then \
			echo -e "\e[1;34m┌─ 󰏗 Installing {{pkg}}...\e[0m"; \
			gum spin --spinner="points" --title="apt update..." --spinner.foreground="33" --title.foreground="33" {{MYSUDO}} apt-get update > /dev/null 2>&1; \
			{{MYSUDO}} apt-get install -y {{pkg}}; \
			clear; \
			echo -e "\e[1;36m└─ 󰄬 {{pkg}} installation completed\e[0m"; \
		else \
			echo -e "\e[1;31m└─ Skipping {{pkg}} installation\e[0m"; \
		fi; \
	else \
		echo -e "\e[1;34m└─ 󰄬 {{pkg}} is already installed\e[0m"; \
	fi

# ----------------------------
# script-step:
# Displays a description, prompts for confirmation and executes a command.
# Usage: just script-step "command" "Description"
script-step cmd description:
	@rich -p "       󱞬 {{description}}" -s "#444444"; \
	RES=$$(gum confirm --show-output "  >> DO WANT TO EXECUTE {{cmd}}?"); \
	tput cuu1; tput el; \
	gum style; \
	if echo "$$RES" | grep -q "Yes"; then \
		just echothis "{{cmd}}"; \
		eval "{{cmd}}"; \
	elif echo "$$RES" | grep -qi "q"; then \
		exit 1; \
	fi

# ----------------------------
# inst-basic-deps:
# Installs the basic dependencies.
inst-basic-deps:
	just isinstalled curl
	just isinstalled wget
	just isinstalled unzip
	just isinstalled shred
	just isinstalled xsel
	just isinstalled fzf
	just isinstalled git

# ----------------------------
# inst-utilities:
# Installs additional utilities.
inst-utilities:
	just isinstalled gron
	just isinstalled xdotool
	just isinstalled wmctrl
	just isinstalled ccrypt

# ----------------------------
# inst-slimjet:
# Downloads and installs the Slimjet browser.
inst-slimjet:
	@curl -L 'https://www.slimjet.com/download.php?version=lnx64&type=deb&beta=&server=' -o slimjet.deb; \
	{{MYSUDO}} apt update; \
	{{MYSUDO}} apt install ./slimjet.deb

# ----------------------------
# edit-visudo:
# Edits the sudoers file to add NOPASSWD for MYUSER.
edit-visudo:
	@just echothis "edit visudo"; \
	if ! grep -q "$$MYUSER ALL=(ALL) NOPASSWD: ALL" /etc/sudoers; then \
		echo "$$MYUSER ALL=(ALL) NOPASSWD: ALL" | {{MYSUDO}} EDITOR=nano tee -a /etc/sudoers; \
	fi

# ----------------------------
# setup-user:
# Prompts the user for a username and machine type.
setup-user:
	@MYUSER=$$(gum write --height=1 --prompt=">> " --no-show-help --placeholder="$$(whoami)" --header="USER:" --value="$$(whoami)"); \
	echo "MYUSER=$$MYUSER"; \
	sleep 0.5; \
	myHEAD=$$(gum write --height=1 --prompt=">> " --no-show-help --placeholder="1=head 0=headless" --header="MACHINE:"); \
	if [ "$$myHEAD" = "headless" ]; then myHEAD="0"; elif [ "$$myHEAD" = "head" ]; then myHEAD="1"; fi; \
	echo "myHEAD=$$myHEAD"; \
	sleep 0.5

# ----------------------------
# create-user-if-not-exists:
# Creates the user if it does not already exist.
create-user-if-not-exists:
	@if [ "$$(whoami)" != "$$MYUSER" ]; then \
		just echothis "Check if user $$MYUSER exists"; \
		if ! id "$$MYUSER" >/dev/null 2>&1; then \
			just echothis "Creating user $$MYUSER..."; \
			{{MYSUDO}} useradd -m -s /bin/bash $$MYUSER; \
			echo "$$MYUSER:$$MYUSER" | {{MYSUDO}} chpasswd; \
			{{MYSUDO}} usermod -aG sudo $$MYUSER; \
			just echothis2 "User $$MYUSER created"; \
		else \
			just echothis "User $$MYUSER already exists"; \
		fi; \
	fi

# ----------------------------
# setup-bitwarden:
# Sets up Bitwarden by ensuring the bws token is available.
setup-bitwarden:
	@VAR=$$(cat /home/abrax/.ssh/bws.dat 2>/dev/null || echo ""); \
	if [ $$(echo $${#VAR}) -ne 94 ]; then rm /home/abrax/.ssh/bws.dat; fi; \
	if [ ! -f /home/abrax/.ssh/bws.dat ]; then \
		echo; \
		read -p "Press enter to continue" dummy; \
		if [ -f /usr/bin/flashpeak-slimjet ]; then \
			/usr/bin/flashpeak-slimjet https://github.com/0abraxas678 & \
			/usr/bin/flashpeak-slimjet https://bitwarden.eu & \
		else \
			echo -e "\e[1;33mPlease visit these URLs in your browser:\e[0m"; \
			echo "https://github.com/abraxas678"; \
			echo "https://bitwarden.eu"; \
		fi; \
		if [ ! -f /home/abrax/.ssh/bws.dat ]; then \
			gum input --password --no-show-help --placeholder="enter bws.dat" > /home/abrax/.ssh/bws.dat; \
		fi; \
		export BWS_ACCESS_TOKEN=$$(cat /home/abrax/.ssh/bws.dat); \
		echo; \
	fi

# ----------------------------
# inst-bws:
# Installs BWS and then updates its configuration.
inst-bws:
	@if ! command -v bws >/dev/null 2>&1; then \
		just echothis "BWS INSTALL"; \
		gum spin --spinner="points" --title="downloading BWS..." --spinner.foreground="33" --title.foreground="33" wget https://github.com/bitwarden/sdk/releases/download/bws-v1.0.0/bws-x86_64-unknown-linux-gnu-1.0.0.zip; \
		gum spin --spinner="points" --title="unzipping BWS..." --spinner.foreground="33" --title.foreground="33" unzip bws-x86_64-unknown-linux-gnu-1.0.0.zip; \
		gum spin --spinner="points" --title="move..." --spinner.foreground="33" --title.foreground="33" {{MYSUDO}} mv bws /usr/bin/; \
		rm -f bws-x86_64-unknown-linux-gnu-1.0.0.zip; \
	fi; \
	just echothis "updating BWS server-base"; \
	bws config server-base https://vault.bitwarden.eu > /home/abrax/tmp/del 2>&1; \
	just echothis2 "$$(cat /home/abrax/tmp/del)"; \
	rm -f /home/abrax/tmp/del; \
	chmod 700 /home/abrax/.ssh; \
	chmod 600 /home/abrax/.ssh/*

# ----------------------------
# inst-chezmoi:
# Installs chezmoi if not already present.
inst-chezmoi:
			wget https://github.com/twpayne/chezmoi/releases/download/v2.58.0/chezmoi_2.58.0_linux_amd64.deb; \
			{{MYSUDO}} apt install -y ./chezmoi_2.58.0_linux_amd64.deb; \
# ----------------------------
# inst-github-cli:
# Installs the GitHub CLI.
inst-github-cli:
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | {{MYSUDO}} dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg;
        echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | {{MYSUDO}} tee /etc/apt/sources.list.d/github-cli.list > /dev/null;
        {{MYSUDO}} apt update;
        {{MYSUDO}} apt install gh;
