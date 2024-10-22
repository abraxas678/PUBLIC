#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.
set -x  # Print commands and their arguments as they are executed.

# Install rich if not already installed
if ! python3 -c "import rich" &> /dev/null; then
    echo "Installing rich for breathtaking output..."
    pip install rich
fi

echo "Creating Python script..."

# Create a Python script for rich output
cat << 'EOF' > rich_output.py
from rich.console import Console
from rich.panel import Panel
from rich.progress import Progress
from rich.live import Live
from rich.table import Table
from rich.layout import Layout
import sys
import time

console = Console()

def create_steps_table(steps, completed):
    table = Table(show_header=False, expand=True)
    for i, step in enumerate(steps, 1):
        status = "[green]✓[/green]" if i in completed else " "
        table.add_row(f"{status} {i}. {step}")
    return Panel(table, title="Installation Steps", expand=False)

class StepTracker:
    _instance = None

    def __init__(self, steps):
        if not StepTracker._instance:
            self.steps = steps.split('|')
            self.completed = set()
            self.layout = Layout()
            self.layout.split(
                Layout(name="steps", size=len(self.steps) + 3),
                Layout(name="output")
            )
            self.layout["steps"].update(create_steps_table(self.steps, self.completed))
            self.live = Live(self.layout, console=console, screen=True, refresh_per_second=4)
            StepTracker._instance = self

    @classmethod
    def get_instance(cls):
        return cls._instance

    def update_steps(self, completed):
        self.completed = set(int(x) for x in completed.split(',') if x)
        self.layout["steps"].update(create_steps_table(self.steps, self.completed))

    def print_output(self, message):
        self.layout["output"].update(Panel(message, expand=False))

    def start(self):
        self.live.start()

    def stop(self):
        self.live.stop()

def print_panel(message):
    tracker = StepTracker.get_instance()
    if tracker:
        tracker.print_output(message)
    else:
        console.print(Panel(message, expand=False))

def run_progress(total, description):
    progress = Progress()
    task = progress.add_task(description, total=total)
    tracker = StepTracker.get_instance()
    if tracker:
        tracker.layout["output"].update(progress)
    else:
        progress.start()
    while not progress.finished:
        progress.update(task, advance=1)
        time.sleep(0.1)
    if not tracker:
        progress.stop()

if __name__ == "__main__":
    print(f"Python script called with arguments: {sys.argv}", file=sys.stderr)
    action = sys.argv[1]
    if action == "init":
        StepTracker(sys.argv[2]).start()
    elif action == "panel":
        print_panel(sys.argv[2])
    elif action == "progress":
        run_progress(int(sys.argv[2]), sys.argv[3])
    elif action == "update_steps":
        tracker = StepTracker.get_instance()
        if tracker:
            tracker.update_steps(sys.argv[2])
    elif action == "stop":
        tracker = StepTracker.get_instance()
        if tracker:
            tracker.stop()
    print("Python script execution completed", file=sys.stderr)
EOF

echo "Python script created."

# Function to check if a package is installed
is_installed() {
    dpkg -s "$1" &> /dev/null
}

# Function to install a package if not already installed
install_package() {
    if ! is_installed "$1"; then
        python3 rich_output.py panel "[bold blue]Installing $1...[/bold blue]"
        sudo apt-get update && sudo apt-get install -y "$1"
        python3 rich_output.py panel "[bold green]✓ $1 installed successfully.[/bold green]"
    else
        python3 rich_output.py panel "[bold yellow]$1 is already installed.[/bold yellow]"
    fi
}

# Function to ask user if they want to install a package
ask_to_install() {
    if ! is_installed "$1"; then
        python3 rich_output.py panel "[bold cyan]Do you want to install $1? (y/n):[/bold cyan]"
        read -r choice
        case "$choice" in 
            y|Y ) return 0;;
            n|N ) return 1;;
            * ) python3 rich_output.py panel "[bold red]Invalid input. Skipping $1.[/bold red]"; return 1;;
        esac
    else
        python3 rich_output.py panel "[bold yellow]$1 is already installed.[/bold yellow]"
        return 1
    fi
}

# Define installation steps
steps="Install required packages|Install optional packages|Install rich-cli|Install GitHub CLI|Install or update rclone beta"
completed=""

echo "Initializing step tracker..."

# Initialize the step tracker
python3 rich_output.py init "$steps"

echo "Step tracker initialized."

# Function to update steps
update_steps() {
    python3 rich_output.py update_steps "$completed"
}

# Main installation process
python3 rich_output.py panel "[bold magenta]Starting Breathtaking Installation Process[/bold magenta]"

# List of required packages
required_packages=("curl" "wget" "unzip" "nano")

# Install required packages with progress bar
python3 rich_output.py panel "[bold blue]Installing required packages...[/bold blue]"
python3 rich_output.py progress ${#required_packages[@]} "Required Packages"
for package in "${required_packages[@]}"; do
    install_package "$package"
done

python3 rich_output.py panel "[bold green]All required packages have been installed or were already present.[/bold green]"
completed="1"
update_steps

# Optional packages
optional_packages=("python3-pip" "pipx" "git" "zoxide")

# Ask and install optional packages
python3 rich_output.py panel "[bold cyan]Optional Packages[/bold cyan]"
for package in "${optional_packages[@]}"; do
    if ask_to_install "$package"; then
        install_package "$package"
        if [ "$package" = "pipx" ]; then
            export PATH="$PATH:$HOME/.local/bin"
        fi
    fi
done
completed="1,2"
update_steps

# Ask and install rich-cli using pipx
if ask_to_install "rich-cli"; then
    if command -v pipx &> /dev/null; then
        python3 rich_output.py panel "[bold blue]Installing rich-cli using pipx...[/bold blue]"
        pipx install rich-cli
        python3 rich_output.py panel "[bold green]✓ rich-cli installed successfully.[/bold green]"
    else
        python3 rich_output.py panel "[bold red]pipx is not installed. Please install pipx first to install rich-cli.[/bold red]"
    fi
fi
completed="1,2,3"
update_steps

# Ask and install gh (GitHub CLI)
if ! command -v gh &> /dev/null; then
    if ask_to_install "gh"; then
        python3 rich_output.py panel "[bold blue]Installing GitHub CLI (gh)...[/bold blue]"
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh
        python3 rich_output.py panel "[bold green]✓ GitHub CLI (gh) installed successfully.[/bold green]"
    fi
else
    python3 rich_output.py panel "[bold yellow]GitHub CLI (gh) is already installed.[/bold yellow]"
fi
completed="1,2,3,4"
update_steps

# Ask and install rclone beta
if ! command -v rclone &> /dev/null; then
    if ask_to_install "rclone beta"; then
        python3 rich_output.py panel "[bold blue]Installing rclone beta...[/bold blue]"
        curl https://rclone.org/install.sh | sudo bash -s beta
        python3 rich_output.py panel "[bold green]✓ rclone beta installed successfully.[/bold green]"
    fi
else
    python3 rich_output.py panel "[bold yellow]rclone is already installed. Updating to beta...[/bold yellow]"
    curl https://rclone.org/install.sh | sudo bash -s beta
    python3 rich_output.py panel "[bold green]✓ rclone updated to beta successfully.[/bold green]"
fi
completed="1,2,3,4,5"
update_steps

python3 rich_output.py panel "[bold green]Installation process completed successfully![/bold green]"
python3 rich_output.py panel "[bold magenta]Thank you for using the Breathtaking Installer![/bold magenta]"

echo "Stopping live display..."

# Stop the live display
python3 rich_output.py stop

echo "Live display stopped."

# Clean up
rm rich_output.py

echo "Script completed."
